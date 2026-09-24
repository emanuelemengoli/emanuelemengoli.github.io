# frozen_string_literal: true

require "date"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"

module RaceSources
  # Combines Switzerland's two national federation calendars — athletics and triathlon —
  # since neither alone covers the country. Both are the first page only (no pagination
  # handling): Swiss Athletics' table is a PrimeFaces datatable that paginates via
  # stateful AJAX postbacks, and Swiss Triathlon's calendar (a WordPress "Modern Events
  # Calendar" plugin) only renders its current/next events per plain page load, walking
  # further months needs its own AJAX action — both out of scope for a simple GET-based
  # scraper. First-page coverage every month, refreshed monthly, is still a real signal.
  class Switzerland < Base
    ATH_URL = "https://alabus.swiss-athletics.ch/satweb/faces/eventcalendar.xhtml?lang=de"
    TRI_URL = "https://swisstriathlon.ch/race-calendar/"
    TRAIL_HINTS = /trail|berglauf|bergauf|alpin|mountain|montagne|montagna/i
    # Swiss Athletics' calendar is every sanctioned athletics event — track meets, throws,
    # combined-events championships, youth/school meetings — not just public road/trail
    # races, and Switzerland's 3 working languages here (de/fr/it) rule out a reliable
    # exclusion list. Require an actual running-race word instead: safer to under- than
    # over-include a javelin final as a "road race."
    RACE_HINTS = /lauf|run\b|course|corsa|corrida|marathon|maratona/i

    def name
      "switzerland"
    end

    def fetch
      athletics + triathlon
    end

    private

    def athletics
      doc = HtmlFetch.get(ATH_URL)
      tbody = doc.at_xpath("//tbody[contains(@id, 'dataTable_EventCalendar')]")
      return [] unless tbody

      tbody.xpath("./tr").filter_map { |row| normalize_athletics(row) }
    rescue StandardError => e
      warn "  ! switzerland/athletics: #{e.class}: #{e.message} — skipping"
      []
    end

    def normalize_athletics(row)
      tds = row.xpath("./td")
      return nil if tds.size < 5

      date = first_date(Text.utf8(tds[0].text))
      return nil unless date

      race_name = Text.utf8(tds[1].text).strip
      return nil if race_name.empty? || !race_name.match?(RACE_HINTS)

      city = Text.utf8(tds[2].text).strip
      canton = Text.utf8(tds[3].text).strip
      region = [city, canton].reject { |s| s.empty? }.join(", ")

      {
        "name" => race_name,
        "date" => date,
        "category" => race_name.match?(TRAIL_HINTS) ? "trail" : "road",
        "country" => "Svizzera",
        "region" => (region unless region.empty?),
        "source" => "switzerland",
        "source_url" => ATH_URL
      }.compact
    end

    def triathlon
      doc = HtmlFetch.get(TRI_URL)
      current_year = nil
      doc.css(".mec-event-list-standard > *").filter_map do |el|
        if el["class"].to_s.include?("mec-month-divider")
          m = el.text.match(/(\d{4})/)
          current_year = m && m[1].to_i
          next nil
        end
        next nil unless el["class"].to_s.include?("mec-event-article")

        normalize_triathlon(el, current_year || Date.today.year)
      end
    rescue StandardError => e
      warn "  ! switzerland/triathlon: #{e.class}: #{e.message} — skipping"
      []
    end

    def normalize_triathlon(article, year)
      link = article.at_css(".mec-event-title a")
      return nil unless link

      race_name = Text.utf8(link.text).strip
      return nil if race_name.empty?

      day_label = article.at_css(".mec-start-date-label")&.text.to_s
      date = date_from_label(day_label, year)
      return nil unless date

      {
        "name" => race_name,
        "date" => date,
        "category" => "triathlon",
        "country" => "Svizzera",
        "url" => link["href"],
        "source" => "switzerland",
        "source_url" => TRI_URL
      }.compact
    end

    # "25.09.2026 - 26.09.2026" or a single "25.09.2026" -> the first date.
    def first_date(text)
      m = text.match(/(\d{2})\.(\d{2})\.(\d{4})/)
      m && Date.new(m[3].to_i, m[2].to_i, m[1].to_i).strftime("%Y-%m-%d")
    rescue ArgumentError
      nil
    end

    # German and English 3-letter month abbreviations both seen on this page depending on
    # locale — "mär"/"mar", "mai"/"may", "okt"/"oct", "dez"/"dec" differ between the two.
    MONTH_ABBR = {
      "jan" => 1, "feb" => 2, "mär" => 3, "mar" => 3, "apr" => 4, "mai" => 5, "may" => 5,
      "jun" => 6, "jul" => 7, "aug" => 8, "sep" => 9, "okt" => 10, "oct" => 10,
      "nov" => 11, "dez" => 12, "dec" => 12
    }.freeze

    # "26 Sep." (no year on the page itself — it comes from the month-divider above it).
    def date_from_label(text, year)
      m = Text.utf8(text).downcase.match(/(\d{1,2})\.?\s*([a-zä]{3,})/)
      return nil unless m

      month = MONTH_ABBR[m[2][0, 3]]
      return nil unless month

      Date.new(year, month, m[1].to_i).strftime("%Y-%m-%d")
    rescue ArgumentError
      nil
    end
  end
end
