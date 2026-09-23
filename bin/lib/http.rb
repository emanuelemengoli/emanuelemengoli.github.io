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
    when Net::HTTPSuccess     then res.body
    when Net::HTTPRedirection then get(res["location"], limit: limit - 1, user_agent: user_agent)
    else raise "HTTP #{res.code} for #{url}"
    end
  end
end
