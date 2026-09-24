# frozen_string_literal: true

require "date"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"

module RaceSources
  # calendariopodismo.it is a dedicated Italian road-race calendar, one page per region
  # (paginated ~40 races/page). Genuinely good data: each race card already carries an
  # ISO date and (usually) lat/lng as data attributes — no guessing, no geocoding needed
  # for most entries — plus a "location / distance" text line.
  class Calendariopodismo < Base
    BASE_URL = "https://www.calendariopodismo.it"
    # All 20 Italian regions' slugs, as linked from the site's own nav. Deliberately
    # excludes the site's own "estero" (abroad) region — races outside Italy belong to
    # this site's own long-tail coverage of *other* sources, not duplicated from here.
    REGIONS = %w[
      abruzzo basilicata calabria campania emilia-romagna friuli-venezia-giulia lazio
      liguria lombardia marche molise piemonte puglia sardegna sicilia toscana
      trentino-alto-adige umbria valle-daosta veneto
    ].freeze
    MAX_PAGES_PER_REGION = 6
    REQUEST_DELAY = 0.4
    TRAIL_HINTS = /trail|sentiero|montagna|bosco|sterrat|cross\b/i

    def name
      "calendariopodismo"
    end

    def fetch
      out = []
      REGIONS.each_with_index do |region, i|
        sleep REQUEST_DELAY unless i.zero?
        out.concat(fetch_region(region))
      end
      out
    rescue StandardError => e
      warn "  ! calendariopodismo: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    def fetch_region(region)
      out = []
      MAX_PAGES_PER_REGION.times do |page|
        sleep REQUEST_DELAY unless page.zero?
        url = page.zero? ? "#{BASE_URL}/regione/#{region}/" : "#{BASE_URL}/regione/#{region}/page/#{page + 1}/?localita=#{region}"
        cards = fetch_page(url)
        break if cards.empty?

        out.concat(cards)
      end
      out
    rescue StandardError => e
      warn "  ! calendariopodismo/#{region}: #{e.class}: #{e.message} — skipping this region"
      out || []
    end

    def fetch_page(url)
      doc = HtmlFetch.get(url)
      doc.css(".gara").filter_map { |el| normalize(el, url) }
    end

    def normalize(el, source_url)
      race_name = Text.utf8(el.at_css(".gara-titolo a")&.text.to_s).strip
      return nil if race_name.empty?

      date = el["data-data"]
      return nil if Text.blank?(date)

      loc_text = Text.utf8(el.at_css(".gara-localita")&.text.to_s).strip
      location, distance = split_localita(loc_text)

      lat = el["data-lat"]
      lng = el["data-lng"]

      {
        "name" => race_name,
        "date" => date,
        "category" => race_name.match?(TRAIL_HINTS) ? "trail" : "road",
        "country" => "Italia",
        "region" => (location unless location.empty?),
        "distance_km" => distance,
        "lat" => (lat.to_f if !Text.blank?(lat)),
        "lng" => (lng.to_f if !Text.blank?(lng)),
        "url" => el.at_css(".gara-titolo a")&.[]("href"),
        "source" => "calendariopodismo",
        "source_url" => source_url
      }.compact
    end

    # "Elba- Capraia - Pianosa / 17km" -> ["Elba- Capraia - Pianosa", 17.0]
    def split_localita(text)
      loc, dist = text.split("/", 2)
      km = dist && dist[/(\d+(?:[.,]\d+)?) ?km/i, 1]&.tr(",", ".")&.to_f
      [loc.to_s.strip, km]
    end
  end
end
