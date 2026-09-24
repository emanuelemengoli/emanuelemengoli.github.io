# frozen_string_literal: true

require "date"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"

module RaceSources
  # Combines Austria's two national federation calendars — athletics (ÖLV's own running-
  # events system) and triathlon (ÖTRV) — since neither alone covers the country. Both
  # are plain server-rendered HTML tables, first page only (ÖTRV's own list is already
  # short; ÖLV doesn't expose a documented page-size/offset param worth guessing at).
  class Austria < Base
    ATH_URL = "https://oelv.athmin.at/runs.aspx?int=cded0020-2621-4904-acb1-e69b883a0501"
    TRI_URL = "https://www.triathlon-austria.at/de/service-termine"
    TRAIL_HINTS = /trail|berglauf|bergauf|alpin|mountain|gebirg/i
    CANCELLED = /abgesagt|cancell?ed|verschoben/i

    def name
      "austria"
    end

    def fetch
      athletics + triathlon
    end

    private

    def athletics
      doc = HtmlFetch.get(ATH_URL)
      table = doc.at_css("table")
      return [] unless table

      table.css("tr").drop(1).filter_map { |row| normalize_athletics(row) }
    rescue StandardError => e
      warn "  ! austria/athletics: #{e.class}: #{e.message} — skipping"
      []
    end

    def normalize_athletics(row)
      tds = row.xpath("./td")
      return nil if tds.size < 4

      date = first_date(Text.utf8(tds[0].text))
      return nil unless date

      race_name = Text.utf8(tds[1].text).strip
      return nil if race_name.empty? || race_name.match?(CANCELLED)

      location = Text.utf8(tds[3].text).strip
      return nil if location.empty? || location.match?(/weltweit|virtual|online/i)

      distances = Text.utf8(tds[2].text).strip

      {
        "name" => race_name,
        "date" => date,
        "category" => "#{race_name} #{distances}".match?(TRAIL_HINTS) ? "trail" : "road",
        "country" => "Austria",
        "region" => location,
        "source" => "austria",
        "source_url" => ATH_URL
      }.compact
    end

    def triathlon
      doc = HtmlFetch.get(TRI_URL)
      table = doc.at_css("table.eventtable")
      return [] unless table

      table.css("tr").drop(1).filter_map { |row| normalize_triathlon(row) }
    rescue StandardError => e
      warn "  ! austria/triathlon: #{e.class}: #{e.message} — skipping"
      []
    end

    def normalize_triathlon(row)
      date = first_date(Text.utf8(row.at_css(".datespan")&.text.to_s))
      return nil unless date

      link = row.at_css("a.titlelink")
      return nil unless link

      race_name = Text.utf8(link.text).strip
      return nil if race_name.empty? || race_name.match?(CANCELLED)

      region = Text.utf8(row.at_css("td.bdsl")&.text.to_s).strip

      {
        "name" => race_name,
        "date" => date,
        "category" => "triathlon",
        "country" => "Austria",
        "region" => (region unless region.empty?),
        "url" => link["href"] && "https://www.triathlon-austria.at#{link['href']}",
        "source" => "austria",
        "source_url" => TRI_URL
      }.compact
    end

    def first_date(text)
      m = text.match(/(\d{2})\.(\d{2})\.(\d{4})/)
      m && Date.new(m[3].to_i, m[2].to_i, m[1].to_i).strftime("%Y-%m-%d")
    rescue ArgumentError
      nil
    end
  end
end
