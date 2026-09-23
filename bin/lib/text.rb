# frozen_string_literal: true

# Small text helpers shared across bin/sync-wines, bin/sync-races and its
# bin/race_sources/*.rb adapters.
module Text
  def self.utf8(str)
    s = str.to_s
    s = s.dup.force_encoding(Encoding::UTF_8) unless s.encoding == Encoding::UTF_8
    s.valid_encoding? ? s : s.scrub
  end

  def self.norm(str)
    utf8(str).unicode_normalize(:nfkd).gsub(/\p{Mn}/, "").downcase.gsub(/[^a-z0-9]+/, " ").strip
  end

  def self.blank?(val)
    return true if val.nil?
    return val.strip.empty? if val.is_a?(String)
    return val.empty? if val.is_a?(Array) || val.is_a?(Hash)

    false
  end

  # Title-case a name/place that arrives ALL CAPS or all-lowercase from a source, without
  # mangling accents or "Mc"/"D'"-style names — good enough for display, not gospel.
  def self.cap(str)
    s = utf8(str).strip
    return s if s.empty?

    s.split(/(\s+|-)/).map { |w| w =~ /\A[\p{L}]/ ? w[0].upcase + w[1..].to_s.downcase : w }.join
  end
end
