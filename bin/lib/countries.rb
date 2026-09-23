# frozen_string_literal: true

require_relative "text"

# The 5 countries this site's races section covers, and the various spellings/codes
# different sources use for them. Country is stored in _data/races.yml in Italian (like
# wines.yml already does), since both sections share one page-level IT->EN translator.
module Countries
  TARGETS = %w[Italia Francia Spagna Svizzera Austria].freeze

  # source token (English name, IOC/ISO code, ...) -> our Italian label. Keys are matched
  # case-insensitively; adapters look up whatever token their source actually prints.
  ALIASES = {
    "italy" => "Italia", "italia" => "Italia", "ita" => "Italia", "it" => "Italia",
    "france" => "Francia", "francia" => "Francia", "fra" => "Francia", "fr" => "Francia",
    "spain" => "Spagna", "spagna" => "Spagna", "espana" => "Spagna", "esp" => "Spagna", "es" => "Spagna",
    "switzerland" => "Svizzera", "svizzera" => "Svizzera", "suisse" => "Svizzera", "schweiz" => "Svizzera",
    "sui" => "Svizzera", "che" => "Svizzera", "ch" => "Svizzera",
    "austria" => "Austria", "aut" => "Austria", "at" => "Austria"
  }.freeze

  # Look up one known token (a full country name or a code) exactly.
  def self.lookup(token)
    ALIASES[Text.norm(token).delete(" ")]
  end

  # Scan free text (e.g. an AIMS LOCATION line, a DUV description) for any recognizable
  # country name — used when a source doesn't give a clean, separate country field.
  # Longer aliases are tried first so "italy" doesn't shadow inside a longer word.
  def self.detect(text)
    hay = Text.norm(text)
    ALIASES.keys.sort_by { |k| -k.length }.each do |token|
      next if token.length <= 2 # 2-letter codes are too ambiguous to free-text scan

      return ALIASES[token] if hay.match?(/(?:\A|\s)#{Regexp.escape(token)}(?:\z|\s)/)
    end
    nil
  end
end
