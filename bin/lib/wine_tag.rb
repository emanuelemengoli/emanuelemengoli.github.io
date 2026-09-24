# frozen_string_literal: true

require_relative "text"

# Detects a "pairs with a wine event/region" theme from a race's own name/region text —
# e.g. the (real, well-known) Marathon des Châteaux du Médoc, a Chianti or Prosecco Hills
# trail, a Rioja vineyard run. Applied centrally in bin/sync-races to every incoming
# entry regardless of source, rather than a hand-curated list of specific races: any
# adapter that happens to pick up a wine-region race gets it tagged automatically.
#
# The wine section on this site (_data/wines.yml) is authored in Italian; this list
# spans the languages/terms actually likely to appear in a race name across our target
# wine-producing countries (France, Italy, Spain, Portugal) plus a few well-known
# wine-region place names in countries that also fall in scope (Napa/Sonoma in the US,
# Mendoza in Argentina).
module WineTag
  KEYWORDS = %w[
    vino vini vigna vigne vigneto vigneti cantina cantine enoturismo
    vin vins vigne vignoble vignobles chateau château crus cru
    medoc médoc bordeaux beaujolais bourgogne burgundy champagne
    chianti prosecco barolo brunello franciacorta valpolicella langhe soave
    vinho vinhos douro
    vino vinedo viñedo rioja ribera jerez cava priorat
    wine wines vineyard vineyards winery wineries
    napa sonoma mendoza
  ].freeze

  def self.match?(*texts)
    hay = Text.norm(texts.compact.join(" "))
    KEYWORDS.any? { |k| hay.match?(/(?:\A|\s)#{Regexp.escape(k)}(?:\z|\s)/) }
  end
end
