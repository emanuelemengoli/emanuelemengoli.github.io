# frozen_string_literal: true

require "date"
require "rexml/document"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/text"
require_relative "../lib/countries"

module RaceSources
  # DUV (Deutsche Ultramarathon-Vereinigung / German Ultramarathon Association) runs the
  # most complete ultramarathon database going — road AND trail ultras, worldwide — and
  # publishes an official RSS feed of upcoming races, meant for exactly this kind of use.
  # https://statistik.d-u-v.org/xml/nextraces_rss.php
  #
  # This RSS feed is a shallow "next ~30 races globally" signal, so after filtering to our
  # 5 countries it may return few or zero entries on some runs — that's expected for v1.
  # Deeper per-country coverage (DUV's filterable HTML calendar, geteventlist.php) is a
  # separate, not-yet-built adapter (see bin/sync-races's open items).
  class Duv < Base
    FEED_URL = "https://statistik.d-u-v.org/xml/nextraces_rss.php"
    PRUNE_HORIZON_DAYS = 7

    def name
      "duv"
    end

    def fetch
      xml = REXML::Document.new(Http.get(FEED_URL))
      cutoff = Date.today - PRUNE_HORIZON_DAYS
      xml.elements.to_a("//item").filter_map { |item| normalize(item, cutoff) }
    rescue StandardError => e
      warn "  ! duv: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    def normalize(item, cutoff)
      title = text_of(item, "title")
      date, race_name = parse_title(title)
      return nil if date.nil? || race_name.nil? || Date.parse(date) < cutoff

      description = text_of(item, "description")
      country, region, distance_km = parse_description(description)
      return nil unless country

      {
        "name" => race_name,
        "date" => date,
        "category" => "ultra", # DUV's whole scope is ultramarathons, road or trail alike
        "country" => country,
        "region" => region,
        "distance_km" => distance_km,
        "url" => text_of(item, "link"),
        "source" => "duv",
        "source_url" => FEED_URL
      }.compact
    end

    def text_of(item, tag)
      el = item.elements[tag]
      el && Text.utf8(el.text.to_s).strip
    end

    # "30.08.-20.10.2026: Self-Transcendence 3100 Mile Race" (multi-day, shares one year)
    # or "26.09.2026: Some Race" (single day). Returns [iso_start_date, name] or [nil, nil].
    def parse_title(title)
      return [nil, nil] if Text.blank?(title)

      if (m = title.match(/\A(\d{2})\.(\d{2})\.-\d{2}\.\d{2}\.(\d{4}):\s*(.+)\z/))
        day, month, year, name = m[1], m[2], m[3], m[4]
      elsif (m = title.match(/\A(\d{2})\.(\d{2})\.(\d{4}):\s*(.+)\z/))
        day, month, year, name = m[1], m[2], m[3], m[4]
      else
        return [nil, nil]
      end

      [Date.new(year.to_i, month.to_i, day.to_i).strftime("%Y-%m-%d"), name.strip]
    rescue ArgumentError
      [nil, nil]
    end

    # "Peschiera del Garda (VR) (ITA), 7000km, " / "New York, NY (USA), 3100mi, "
    # -> [country, region, distance_km] (any of which may come back nil).
    def parse_description(desc)
      d = desc.to_s
      codes = d.scan(/\(([A-Za-z]{2,3})\)/).flatten
      country = codes.reverse.filter_map { |c| Countries.lookup(c) }.first

      parts = d.split(",").map(&:strip).reject(&:empty?)
      dist_part = parts.find { |p| p.match?(/\A\d+(?:\.\d+)? ?(km|mi)\z/i) }
      distance_km = dist_part && to_km(dist_part)

      region_parts = parts.reject { |p| p.equal?(dist_part) }
      region = region_parts.join(", ").gsub(/ ?\([A-Za-z]{2,3}\)/, "").squeeze(" ").strip

      [country, (region unless region.empty?), distance_km]
    end

    def to_km(part)
      m = part.match(/\A(\d+(?:\.\d+)?) ?(km|mi)\z/i)
      return nil unless m

      m[2].casecmp("mi").zero? ? (m[1].to_f * 1.60934).round(1) : m[1].to_f
    end
  end
end
