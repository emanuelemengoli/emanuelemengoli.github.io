# frozen_string_literal: true

require "json"
require_relative "http"

# Tiny OpenStreetMap Nominatim geocoder with a local JSON cache and the 1-request/second
# rate limit Nominatim's usage policy requires. Extracted from bin/sync-wines so
# bin/sync-races can share it: races will do far more lookups (hundreds of venues vs. a
# handful of wine producers), so the rate-limit/caching logic needs to live in one place
# rather than risk the two scripts drifting apart on Nominatim's usage policy.
module Geocode
  class Client
    attr_reader :lookups

    def initialize(cache_file)
      @cache_file = cache_file
      @cache = File.exist?(cache_file) ? (JSON.parse(File.read(cache_file)) rescue {}) : {}
      @lookups = 0
    end

    # parts: ordered from most to least specific (e.g. venue, region, country). Falls
    # back to a shorter query (dropping the first part) if the full query has no hit —
    # useful when a precise venue name doesn't geocode but "region, country" does.
    def lookup(*parts)
      query = parts.map { |p| p.to_s.strip }.reject(&:empty?).join(", ")
      return nil if query.empty?
      return @cache[query] if @cache.key?(query)

      result = nominatim(query)
      if result.nil? && parts.length > 1
        fallback = parts.drop(1).map { |p| p.to_s.strip }.reject(&:empty?).join(", ")
        result = nominatim(fallback) unless fallback.empty? || fallback == query
      end
      @cache[query] = result
      result
    end

    def save
      File.write(@cache_file, JSON.pretty_generate(@cache) + "\n")
    end

    private

    def nominatim(query)
      uri = URI("https://nominatim.openstreetmap.org/search")
      uri.query = URI.encode_www_form(q: query, format: "json", limit: 1, addressdetails: 0)
      body = Http.get(uri.to_s)
      sleep 1 # Nominatim usage policy: <= 1 request/second
      @lookups += 1
      hit = JSON.parse(body).first
      hit && [hit["lat"].to_f.round(6), hit["lon"].to_f.round(6)]
    rescue StandardError => e
      warn "  ! geocode failed for #{query.inspect}: #{e.class}: #{e.message}"
      nil
    end
  end
end
