# frozen_string_literal: true

require_relative "text"

# Best-effort distance-from-race-name inference, shared by every road-race adapter (a
# race name usually states its distance somewhere — "Marathon de X", "Semi de Y",
# "10km de Z" — even when the source itself has no separate distance field).
module DistanceGuess
  HALF_MARATHON_RE = /half.?marathon|halbmarathon|semi.?marathon|demi.?marathon|1\/2.?marathon|mezza ?maratona/i
  MARATHON_RE = /marathon|maratona/i

  def self.km(text)
    n = Text.norm(text)
    return 21.1 if n.match?(HALF_MARATHON_RE)
    return 42.195 if n.match?(MARATHON_RE)

    m = n.match(/\b(\d+(?:\.\d+)?) ?km\b/) || n.match(/\b(\d+) ?k\b/)
    m && m[1].to_f
  end
end
