# frozen_string_literal: true

require "date"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"

module RaceSources
  # FITRI (Federazione Italiana Triathlon) publishes its race calendar as plain
  # server-rendered Joomla HTML at fitri.it — normally straightforward to scrape, but the
  # site was returning a site-wide 503 for the whole time this adapter was written and
  # tested, so this is built from a confirmed archived snapshot of the page's markup
  # rather than a live response. The #fetch rescue makes that safe either way: if the
  # outage is still ongoing on a given sync run, this just logs a warning and contributes
  # nothing that run, same as any other source having an off day — but the selectors
  # here should be spot-checked against a live page once fitri.it is back.
  class Fitri < Base
    BASE_URL = "https://www.fitri.it/it/gare/calendario.html"
    MAX_PAGES = 10
    PAGE_SIZE = 20
    MONTHS_IT = %w[gen feb mar apr mag giu lug ago set ott nov dic].freeze

    def name
      "fitri"
    end

    def fetch
      out = []
      MAX_PAGES.times do |i|
        sleep 0.4 unless i.zero?
        page_items = fetch_page(i * PAGE_SIZE)
        break if page_items.empty?

        out.concat(page_items)
      end
      out
    rescue StandardError => e
      warn "  ! fitri: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    def fetch_page(start)
      url = start.zero? ? BASE_URL : "#{BASE_URL}?start=#{start}"
      doc = HtmlFetch.get(url)
      doc.css("div.evento-item").filter_map { |el| normalize(el) }
    rescue StandardError => e
      warn "  ! fitri: #{e.class}: #{e.message} — stopping pagination"
      []
    end

    def normalize(el)
      race_name = Text.utf8(el.at_css(".denominazione")&.text.to_s).strip
      return nil if race_name.empty?

      date = extract_date(el)
      return nil unless date

      location = Text.utf8(el.at_css(".luogo")&.text.to_s).strip

      {
        "name" => race_name,
        "date" => date,
        "category" => "triathlon",
        "country" => "Italia",
        "region" => (location unless location.empty?),
        "source" => "fitri",
        "source_url" => BASE_URL
      }.compact
    end

    def extract_date(el)
      begin_block = el.at_css(".date-begin") || el
      day = begin_block.at_css(".date-day")&.text.to_s.strip
      month = begin_block.at_css(".date-month")&.text.to_s.strip
      year = begin_block.at_css(".date-year")&.text.to_s.strip
      return nil if day.empty? || month.empty? || year.empty?

      month_num = MONTHS_IT.index { |m| Text.norm(month).start_with?(m) }
      return nil unless month_num

      Date.new(year.to_i, month_num + 1, day.to_i).strftime("%Y-%m-%d")
    rescue ArgumentError
      nil
    end
  end
end
