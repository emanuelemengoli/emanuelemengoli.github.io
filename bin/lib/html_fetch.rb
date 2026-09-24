# frozen_string_literal: true

require "nokogiri"
require_relative "http"

# Fetch + parse an HTML page in one step, always telling Nokogiri the body is UTF-8
# explicitly. Several of the sites bin/race_sources/ scrapes have no in-document
# <meta charset> tag, and Nokogiri's own charset-sniffing then guesses wrong (usually
# Latin-1) even when the actual bytes are correct UTF-8, silently corrupting every
# accented character. Http.get already normalizes the string's Ruby encoding tag; this
# just makes sure Nokogiri is told the same thing instead of re-guessing.
module HtmlFetch
  def self.get(url, **opts)
    Nokogiri::HTML(Http.get(url, **opts), nil, "UTF-8")
  end
end
