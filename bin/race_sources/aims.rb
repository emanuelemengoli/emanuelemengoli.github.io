# frozen_string_literal: true

require "date"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/text"
require_relative "../lib/countries"
require_relative "../lib/distance_guess"

module RaceSources
  # AIMS (Association of International Marathons and Distance Races) publishes an
  # official iCalendar feed of its member races — road races worldwide, meant for exactly
  # this kind of subscribe/sync use. https://aims-worldrunning.org/events.ics
  #
  # The feed carries no explicit category/distance field, so both are inferred from the
  # race name (best-effort; a miss just leaves distance_km nil, which the finder already
  # treats as "unknown" rather than excluding the race).
  class Aims < Base
    FEED_URL = "https://aims-worldrunning.org/events.ics"
    PRUNE_HORIZON_DAYS = 7 # keep in step with bin/sync-races' own pruning window

    def name
      "aims"
    end

    def fetch
      body = Http.get(FEED_URL)
      cutoff = Date.today - PRUNE_HORIZON_DAYS
      parse_vevents(body).filter_map { |ev| normalize(ev, cutoff) }
    rescue StandardError => e
      warn "  ! aims: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    # RFC5545: continuation lines start with a single space or tab (line "folding").
    def unfold(text)
      lines = []
      Text.utf8(text).each_line do |raw|
        line = raw.chomp("\r\n").chomp("\n")
        if line.start_with?(" ", "\t") && !lines.empty?
          lines[-1] += line[1..]
        else
          lines << line
        end
      end
      lines
    end

    def parse_vevents(body)
      events = []
      current = nil
      unfold(body).each do |line|
        case line
        when "BEGIN:VEVENT" then current = {}
        when "END:VEVENT"
          events << current if current
          current = nil
        else
          next unless current

          key_part, value = line.split(":", 2)
          next unless value

          key = key_part.split(";").first.to_s.strip.upcase
          current[key] = unescape(value)
        end
      end
      events
    end

    def unescape(value)
      value.gsub(/\\[,;nN\\]/) { |m| { "\\," => ",", "\\;" => ";", "\\n" => "\n", "\\N" => "\n", "\\\\" => "\\" }[m] }
    end

    def normalize(ev, cutoff)
      name  = ev["SUMMARY"].to_s.strip
      loc   = ev["LOCATION"].to_s.strip
      date  = parse_date(ev["DTSTART"])
      return nil if name.empty? || date.nil? || Date.parse(date) < cutoff

      country = Countries.detect(loc) || Countries.detect(ev["DESCRIPTION"])
      return nil unless country

      {
        "name" => name,
        "date" => date,
        "category" => "road",
        "country" => country,
        "region" => loc.split(",").first(loc.split(",").length - 1).join(",").strip,
        "distance_km" => DistanceGuess.km(name),
        "organizer" => ev["ORGANIZER"],
        "url" => normalize_url(ev["URL"]),
        "source" => "aims",
        "source_url" => FEED_URL
      }.compact
    end

    def parse_date(raw)
      return nil if Text.blank?(raw)

      Date.strptime(raw[0, 8], "%Y%m%d").strftime("%Y-%m-%d")
    rescue ArgumentError
      nil
    end

    def normalize_url(raw)
      return nil if Text.blank?(raw)

      u = raw.strip
      u.match?(%r{\Ahttps?://}i) ? u : "https://#{u}"
    end

  end
end
