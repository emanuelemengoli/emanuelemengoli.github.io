# frozen_string_literal: true

require "date"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"

module RaceSources
  # FISky (Federazione Italiana Skyrunning) publishes one plain HTML table per year at a
  # predictable URL — no pagination, the whole season is on one page. The year is baked
  # into the URL itself, so this fetches this year's and next year's pages (a 404 on a
  # not-yet-published year is just skipped, not an error).
  class SkyrunningIt < Base
    BASE = "https://www.skyrunningitalia.it/pages/Calendario-gare-%d"

    def name
      "skyrunning_it"
    end

    def fetch
      years = [Date.today.year, Date.today.year + 1].uniq
      years.flat_map { |y| fetch_year(y) }
    end

    private

    def fetch_year(year)
      url = format(BASE, year)
      doc = HtmlFetch.get(url)
      table = doc.at_css("table")
      return [] unless table

      table.css("tr").filter_map { |row| normalize(row, url) }
    rescue StandardError => e
      warn "  ! skyrunning_it/#{year}: #{e.class}: #{e.message} — skipping this year"
      []
    end

    def normalize(row, source_url)
      tds = row.css("td")
      return nil if tds.size < 4

      date = extract_date(tds[0].text)
      return nil unless date

      link = tds[1].at_css("a")
      race_name = Text.utf8((link || tds[1]).text).strip
      return nil if race_name.empty?

      series = Text.utf8(tds[2].text).strip
      location = Text.utf8(tds[3].text).strip

      {
        "name" => race_name,
        "date" => date,
        "category" => "trail", # skyrunning is mountain/technical trail running by definition
        "country" => "Italia",
        "region" => (location unless location.empty?),
        "series" => (series unless series.empty?),
        "url" => link && link["href"],
        "source" => "skyrunning_it",
        "source_url" => source_url
      }.compact
    end

    def extract_date(text)
      m = Text.utf8(text).match(%r{(\d{2})/(\d{2})/(\d{4})})
      m && Date.new(m[3].to_i, m[2].to_i, m[1].to_i).strftime("%Y-%m-%d")
    rescue ArgumentError
      nil
    end
  end
end
