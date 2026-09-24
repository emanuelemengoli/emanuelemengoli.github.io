# frozen_string_literal: true

require "date"
require "json"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"
require_relative "../lib/countries"

module RaceSources
  # UTMB World Series' event list page is a Next.js app, but the full event array is
  # embedded server-side as JSON in a <script id="__NEXT_DATA__"> tag — no headless
  # browser needed, just parse that one script's text. Each event already carries its own
  # lat/lng, so these entries skip geocoding entirely.
  #
  # (ITRA's own race calendar was checked too: it loads via client-side JS and the site
  # sits behind a bot-challenging WAF that blocks repeated plain HTTP requests, so it's
  # not usable this way — UTMB's own World Series list is the trail source instead.)
  class Utmb < Base
    PAGE_URL = "https://utmb.world/utmb-world-series-events"

    def name
      "utmb"
    end

    def fetch
      doc = HtmlFetch.get(PAGE_URL)
      script = doc.at_css("script#__NEXT_DATA__")
      return [] unless script

      data = JSON.parse(script.text)
      events = data.dig("props", "pageProps", "eventsTopBar") || []
      events.filter_map { |ev| normalize(ev) }
    rescue StandardError => e
      warn "  ! utmb: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    def normalize(ev)
      country = Countries.lookup(ev["countryCode"])
      return nil unless country

      title = Text.utf8(ev["title"]).strip
      date = ev["dateBegin"]
      return nil if title.empty? || Text.blank?(date)

      {
        "name" => title,
        "date" => date,
        "category" => "trail",
        "country" => country,
        "region" => ev["placeName"],
        "lat" => ev["latitude"],
        "lng" => ev["longitude"],
        "series" => "UTMB World Series",
        "url" => ev["url"],
        "source" => "utmb",
        "source_url" => PAGE_URL
      }.compact
    end
  end
end
