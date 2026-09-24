# frozen_string_literal: true

require "net/http"
require "uri"

# Minimal HTTP GET with redirect-following and a real User-Agent, shared by every sync
# script under bin/ (bin/sync-wines, bin/sync-races and its bin/race_sources/*.rb
# adapters) so timeout/redirect/UA behaviour stays in one place instead of drifting
# apart across scripts that all do "fetch a URL, follow redirects, be polite."
module Http
  USER_AGENT = "emanuelemengoli.github.io data sync " \
               "(+https://github.com/emanuelemengoli/emanuelemengoli.github.io)"

  def self.get(url, limit: 5, user_agent: USER_AGENT)
    raise "too many redirects for #{url}" if limit <= 0

    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = user_agent
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                          open_timeout: 15, read_timeout: 30) { |http| http.request(req) }
    case res
    when Net::HTTPSuccess     then to_utf8(res.body, res.type_params["charset"])
    when Net::HTTPRedirection then get(res["location"], limit: limit - 1, user_agent: user_agent)
    else raise "HTTP #{res.code} for #{url}"
    end
  end

  # Net::HTTP hands back the body as raw bytes (ASCII-8BIT), with no encoding applied
  # from the Content-Type header — left alone, a downstream Nokogiri/REXML parser then
  # has to guess the charset itself from document content, and a page with no in-body
  # <meta charset> (several of the sites bin/race_sources/ scrapes have none) gets
  # silently mis-detected, corrupting every accented character. Normalize to a correctly
  # tagged UTF-8 string once, here, so every caller gets text that's actually right.
  def self.to_utf8(body, charset)
    charset = "UTF-8" if charset.nil? || charset.empty?
    body.dup.force_encoding(charset).encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
  rescue ArgumentError, EncodingError
    body.dup.force_encoding(Encoding::UTF_8).scrub
  end
end
