# frozen_string_literal: true

require "date"
require "uri"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/text"
require_relative "../lib/distance_guess"

module RaceSources
  # FFA (Fédération Française d'Athlétisme) publishes its full competition calendar at
  # athle.fr, covering road AND trail running under one "Running" bucket (there's no
  # separate trail filter — race names are keyword-classified instead, best-effort).
  #
  # The calendar REQUIRES at least one filter beyond the season — an unfiltered query is
  # rejected outright ("criteria insufficient") — so this queries once per competition
  # *level* (niveau). Deliberately excludes "Départemental": that level alone runs into
  # the thousands of small local races nationwide (needs its own per-region pagination
  # loop, and isn't the kind of race worth surfacing for season planning) — every level
  # above it stays comfortably on one page per query.
  class Ffa < Base
    BASE_URL = "https://www.athle.fr/bases/liste.aspx"
    NIVEAUX = ["Régional", "National", "Interrégional", "International",
               "Européen", "Méditérranéen", "Mondial", "Olympique", "Francophonie"].freeze
    REQUEST_DELAY = 0.4
    TRAIL_HINTS = /trail|sentier|montagne|nature|foret|forêt|chemin|randonn/i
    # FFA licenses French athletes who then race abroad, and lists some of those results
    # in its own calendar with a "(Xxx)" country suffix on the title — e.g. "Petra Desert
    # Marathon (Jor)", "Trail Du Besso (Sui)". Only the ones in our other 4 target
    # countries are worth keeping (re-tagged); anything else true-foreign is dropped, not
    # miscounted as being in France.
    FOREIGN_SUFFIX = /\s*\(([A-Za-z]{3})\)\z/
    FOREIGN_COUNTRY = { "sui" => "Svizzera", "esp" => "Spagna", "ita" => "Italia", "aut" => "Austria" }.freeze

    def name
      "ffa"
    end

    def fetch
      season = current_season
      out = []
      NIVEAUX.each_with_index do |niveau, i|
        sleep REQUEST_DELAY unless i.zero?
        out.concat(fetch_niveau(season, niveau))
      end
      out
    rescue StandardError => e
      warn "  ! ffa: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    # FFA's "saison" runs September -> August; pick whichever season contains today.
    def current_season(today = Date.today)
      today.month >= 9 ? today.year + 1 : today.year
    end

    def fetch_niveau(season, niveau)
      html = Http.get(query_url(season, niveau))
      parse_page(html)
    rescue StandardError => e
      warn "  ! ffa/#{niveau}: #{e.class}: #{e.message} — skipping this level"
      []
    end

    def query_url(season, niveau)
      params = {
        frmpostback: "true", frmbase: "calendrier", frmmode: "1", frmespace: "0",
        frmsaisonffa: season, frmtype1: "Running", frmniveau: niveau
      }
      "#{BASE_URL}?#{URI.encode_www_form(params)}"
    end

    def parse_page(html)
      doc = Nokogiri::HTML(html, nil, "UTF-8")
      table = doc.at_xpath("//table[@id='ctnCalendrier']")
      return [] unless table

      table.xpath("./tr | ./tbody/tr").filter_map { |row| parse_row(row) }
    end

    def parse_row(row)
      return nil if row["class"].to_s.include?("detail-row")

      tds = row.xpath("./td")
      return nil if tds.size < 3

      date = date_from_href(tds[0].at_xpath(".//a")&.[]("href"))
      return nil unless date

      race_name = Text.utf8(tds[1].text).strip
      return nil if race_name.empty?

      country = "Francia"
      if (m = race_name.match(FOREIGN_SUFFIX))
        mapped = FOREIGN_COUNTRY[m[1].downcase]
        return nil unless mapped # a true-foreign result FFA happens to list — not ours to show

        country = mapped
        race_name = race_name.sub(FOREIGN_SUFFIX, "").strip
      end

      location = Text.utf8(tds[2].children.first&.text.to_s).strip
      # The "Fiche" column (a per-competition detail page, not the calendar search
      # itself) — without it, `url` was simply absent and the finder had nothing
      # race-specific to link to.
      fiche = tds[6]&.at_xpath(".//a")&.[]("href")

      {
        "name" => race_name,
        "date" => date,
        "category" => race_name.match?(TRAIL_HINTS) ? "trail" : "road",
        "country" => country,
        "region" => (location unless location.empty?),
        "distance_km" => DistanceGuess.km(race_name),
        "url" => (fiche && URI.join("https://www.athle.fr", fiche).to_s),
        "source" => "ffa",
        "source_url" => BASE_URL
      }.compact
    end

    # The date link's href carries the real numeric date as query params — more reliable
    # than parsing the French month name shown in the link text, which has no year at all
    # (the year only appears once, on a month-separator row above a whole block of races).
    def date_from_href(href)
      return nil unless href

      q = URI.decode_www_form(URI(href).query.to_s).to_h.transform_keys { |k| k.downcase }
      d, m, y = q["frmdate_j1"], q["frmdate_m1"], q["frmdate_a1"]
      return nil unless d && m && y

      Date.new(y.to_i, m.to_i, d.to_i).strftime("%Y-%m-%d")
    rescue StandardError
      nil
    end
  end
end
