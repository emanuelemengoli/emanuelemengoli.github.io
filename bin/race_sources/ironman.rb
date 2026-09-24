# frozen_string_literal: true

require "date"
require "json"
require "net/http"
require "uri"
require "nokogiri"
require_relative "base"
require_relative "../lib/http"
require_relative "../lib/html_fetch"
require_relative "../lib/text"
require_relative "../lib/countries"

module RaceSources
  # ironman.com's own race listing is a Drupal "Views" block rendered client-side via
  # Drupal's generic /views/ajax endpoint — not present in the plain page HTML. Cracked
  # by replaying that AJAX call directly: fetch the listing page once to read the view's
  # identity + the page's `ajaxPageState.libraries` token out of its embedded
  # `drupal-settings-json` script, then POST that same payload to /views/ajax?page=N,
  # incrementing N (Drupal's infinite-scroll pager) until a page comes back with no
  # cards. www.ironman.com is Cloudflare-blocked outright; the bare ironman.com domain
  # (what this uses) isn't.
  class Ironman < Base
    RACES_URL = "https://ironman.com/races"
    AJAX_URL = "https://ironman.com/views/ajax"
    MAX_PAGES = 30
    REQUEST_DELAY = 0.4

    def name
      "ironman"
    end

    def fetch
      settings = fetch_settings
      return [] unless settings

      out = []
      MAX_PAGES.times do |page|
        sleep REQUEST_DELAY unless page.zero?
        fragment = fetch_page(settings, page)
        break unless fragment

        cards = parse_cards(fragment)
        break if cards.empty?

        out.concat(cards)
      end
      out
    rescue StandardError => e
      warn "  ! ironman: #{e.class}: #{e.message} — skipping this source for this run"
      []
    end

    private

    def fetch_settings
      doc = HtmlFetch.get(RACES_URL)
      script = doc.at_css('script[data-drupal-selector="drupal-settings-json"]')
      return nil unless script

      json = JSON.parse(script.text)
      view = json.dig("views", "ajaxViews")&.values&.first
      return nil unless view

      { view: view, libraries: json.dig("ajaxPageState", "libraries") }
    end

    def fetch_page(settings, page)
      view = settings[:view]
      params = [
        %w[view_name] + [view["view_name"]],
        %w[view_display_id] + [view["view_display_id"]],
        %w[view_args] + [view["view_args"]],
        %w[view_path] + [view["view_path"]],
        %w[view_dom_id] + [view["view_dom_id"]],
        %w[pager_element] + [view["pager_element"]],
        ["page", page.to_s],
        ["ajax_page_state[theme]", "ironman"],
        ["ajax_page_state[theme_token]", ""],
        ["ajax_page_state[libraries]", settings[:libraries]]
      ]
      body = params.map { |k, v| "#{URI.encode_www_form_component(k)}=#{URI.encode_www_form_component(v.to_s)}" }.join("&")
      resp = post(("#{AJAX_URL}?page=#{page}"), body)
      commands = JSON.parse(resp)
      insert = commands.find { |c| c["command"] == "insert" && c["data"].to_s.length > 1000 }
      insert && insert["data"]
    rescue StandardError => e
      warn "  ! ironman: page #{page}: #{e.class}: #{e.message} — stopping pagination"
      nil
    end

    def post(url, body)
      uri = URI(url)
      req = Net::HTTP::Post.new(uri)
      req["User-Agent"] = Http::USER_AGENT
      req["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
      req["X-Requested-With"] = "XMLHttpRequest"
      req.body = body
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 15, read_timeout: 30) { |http| http.request(req) }
      raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

      Http.to_utf8(res.body, res.type_params["charset"])
    end

    def parse_cards(fragment_html)
      doc = Nokogiri::HTML(fragment_html, nil, "UTF-8")
      doc.css("[data-race-id]").filter_map { |el| normalize(el) }
    end

    def normalize(card)
      race_name = Text.utf8(card.at_css("h2")&.text.to_s).strip
      return nil if race_name.empty?

      date_text = Text.utf8(card.at_css(".date")&.text.to_s).strip
      date = parse_date(date_text)
      return nil unless date

      location = Text.utf8(card.at_css(".location .label")&.text.to_s).strip
      flag = card.at_css('.country-flag-formatter img')&.[]("src").to_s
      code = flag[%r{flagsvg/4x3/([a-z]{2})\.svg}i, 1]
      country = code && Countries.lookup(code)
      return nil unless country

      {
        "name" => race_name,
        "date" => date,
        "category" => "triathlon",
        "country" => country,
        "region" => (location unless location.empty?),
        "series" => (race_name.match?(/70\.3/) ? "IRONMAN 70.3" : "IRONMAN"),
        "url" => "https://ironman.com/race/#{card['data-race-id']}",
        "source" => "ironman",
        "source_url" => RACES_URL
      }.compact
    end

    MONTHS_EN = %w[january february march april may june july august september october november december].freeze

    # "September 12–13, 2026" or "September 12, 2026" -> the first day.
    def parse_date(text)
      m = text.match(/([A-Za-z]+)\s+(\d{1,2})(?:[–-]\d{1,2})?,\s*(\d{4})/)
      return nil unless m

      month = MONTHS_EN.index { |mo| mo.start_with?(Text.norm(m[1])[0, 3]) }
      return nil unless month

      Date.new(m[3].to_i, month + 1, m[2].to_i).strftime("%Y-%m-%d")
    rescue ArgumentError
      nil
    end
  end
end
