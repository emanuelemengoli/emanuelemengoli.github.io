# frozen_string_literal: true

require "date"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"
require_relative "../lib/countries"

module RaceSources
  # FFTRI's *international* calendar pages (Monde / Europe — its national-championship-
  # stages page was checked separately and is stale/undated, not used here) are plain
  # prose, not a table: one loosely-formatted line per race, e.g.
  #   "20 et 21 juin : Quiberon (FRA) – Mixed Relay Series"
  #   "16-18 octobre : Triathlon Youth Championships – Melilla (Esp)"
  # This is a best-effort line parser, not a clean scrape — lines that don't match the
  # expected "date : text (COUNTRY)" shape are silently skipped rather than guessed at.
  class Fftri < Base
    PAGES = %w[
      https://www.fftri.com/competitions/competitions-internationales/monde/
      https://www.fftri.com/competitions/competitions-internationales/europe/
    ].freeze

    MONTHS_FR = %w[janvier fevrier mars avril mai juin juillet aout septembre
                   octobre novembre decembre].freeze

    def name
      "fftri"
    end

    def fetch
      PAGES.flat_map { |url| fetch_page(url) }
    rescue StandardError => e
      warn "  ! fftri: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    def fetch_page(url)
      doc = HtmlFetch.get(url)
      full_text = doc.css(".et_pb_text_inner").map(&:text).join("\n")
      year = (full_text[/\b(20\d{2})\b/, 1] || Date.today.year.to_s).to_i

      full_text.each_line.filter_map { |line| parse_line(line, year, url) }
    rescue StandardError => e
      warn "  ! fftri: #{url}: #{e.class}: #{e.message} — skipping this page"
      []
    end

    # "20 et 21 juin : Quiberon (FRA) – Mixed Relay Series" — day[-day|et day] month : rest
    # (one month, stated once for the whole range).
    LINE_SAME_MONTH = /\A(\d{1,2})(?:er)?(?:\s*(?:[-–]|et)\s*\d{1,2}(?:er)?)?
                        \s+([a-zàâäéèêëïîôöùûüç]+)\s*[:\-–]\s*(.+)\z/ix
    # "27 février – 1er mars : Padola (ITA)" — day month – day month : rest (month stated
    # twice, once per side of a range that crosses a month boundary). Tried first: without
    # it, the "– 1er mars" continuation gets misread as the date/name separator and leaks
    # into the extracted name.
    LINE_CROSS_MONTH = /\A(\d{1,2})(?:er)?\s+([a-zàâäéèêëïîôöùûüç]+)
                         \s*(?:[-–]|et)\s*\d{1,2}(?:er)?\s+[a-zàâäéèêëïîôöùûüç]+
                         \s*[:\-–]\s*(.+)\z/ix

    def parse_line(line, year, source_url)
      l = Text.utf8(line).strip
      return nil if l.empty?

      m = l.match(LINE_CROSS_MONTH) || l.match(LINE_SAME_MONTH)
      return nil unless m

      day = m[1].to_i
      month = MONTHS_FR.index { |mo| Text.norm(m[2]).start_with?(mo[0, 4]) }
      return nil unless month

      date = begin
        Date.new(year, month + 1, day)
      rescue ArgumentError
        nil
      end
      return nil unless date

      rest = m[3].strip
      country = Countries.detect(rest)
      return nil unless country

      race_name = extract_name(rest)
      return nil if race_name.empty?

      {
        "name" => race_name,
        "date" => date.strftime("%Y-%m-%d"),
        "category" => "triathlon",
        "country" => country,
        "source" => "fftri",
        "source_url" => source_url
      }.compact
    end

    # "Triathlon Championships – Tarragone (Esp)  (Standard)" -> "Triathlon Championships"
    # "Quiberon (FRA) – Mixed Relay Series" -> "Quiberon" (no separate name given, so the
    # city itself is the best available label).
    def extract_name(rest)
      without_parens = rest.gsub(/\([^)]*\)/, " ").squeeze(" ").strip
      without_parens.split(/[-–]/).first.to_s.strip
    end
  end
end
