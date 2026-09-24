# frozen_string_literal: true

require_relative "text"

# The countries this site's races section covers, and the various spellings/codes
# different sources use for each. Country is stored in _data/races.yml in Italian (like
# wines.yml already does), since both sections share one page-level IT->EN translator.
#
# Scope (owner's call): Italy, France, Spain, the Nordic countries, Portugal,
# Switzerland, Austria, Greece, the UK, the Netherlands; South America; North & Central
# America; Japan. Deliberately not "all of Europe" or "everywhere UTMB/Ironman happen to
# have a race" — a handful of countries those sources do cover (Germany, Croatia,
# Romania, Slovenia, Thailand, Malaysia, Indonesia, Vietnam, Taiwan, South Korea, China,
# Hong Kong, Oman, Turkey, Australia, New Zealand, South Africa, Andorra, Latvia) are
# outside this list on purpose and get filtered out like any other out-of-scope country.
module Countries
  TARGETS = %w[
    Italia Francia Spagna Svizzera Austria Grecia Portogallo Regno\ Unito Paesi\ Bassi
    Norvegia Svezia Danimarca Finlandia Islanda
    Stati\ Uniti Canada Messico Costa\ Rica Panama Guatemala Honduras
    Brasile Argentina Cile Peru Colombia Ecuador Uruguay Paraguay Bolivia Venezuela
    Giappone
  ].freeze

  # source token (English/native name, ISO-3166 alpha-2, IOC/federation-style alpha-3,
  # ...) -> our Italian label. Keys are matched case-insensitively; adapters look up
  # whatever token their source actually prints.
  ALIASES = {
    # -- Europe --
    "italy" => "Italia", "italia" => "Italia", "italie" => "Italia", "ita" => "Italia", "it" => "Italia",
    "france" => "Francia", "francia" => "Francia", "fra" => "Francia", "fr" => "Francia",
    "spain" => "Spagna", "spagna" => "Spagna", "espana" => "Spagna", "espagne" => "Spagna",
    "esp" => "Spagna", "es" => "Spagna",
    "switzerland" => "Svizzera", "svizzera" => "Svizzera", "suisse" => "Svizzera", "schweiz" => "Svizzera",
    "sui" => "Svizzera", "che" => "Svizzera", "ch" => "Svizzera",
    "austria" => "Austria", "autriche" => "Austria", "aut" => "Austria", "at" => "Austria",
    "greece" => "Grecia", "grecia" => "Grecia", "hellas" => "Grecia", "grc" => "Grecia", "gre" => "Grecia", "gr" => "Grecia",
    "portugal" => "Portogallo", "portogallo" => "Portogallo", "por" => "Portogallo", "prt" => "Portogallo", "pt" => "Portogallo",
    "unitedkingdom" => "Regno Unito", "uk" => "Regno Unito", "greatbritain" => "Regno Unito",
    "regnounito" => "Regno Unito", "gbr" => "Regno Unito", "gb" => "Regno Unito",
    "netherlands" => "Paesi Bassi", "paesibassi" => "Paesi Bassi", "holland" => "Paesi Bassi",
    "nederland" => "Paesi Bassi", "ned" => "Paesi Bassi", "nld" => "Paesi Bassi", "nl" => "Paesi Bassi",
    "norway" => "Norvegia", "norvegia" => "Norvegia", "norge" => "Norvegia", "nor" => "Norvegia", "no" => "Norvegia",
    "sweden" => "Svezia", "svezia" => "Svezia", "sverige" => "Svezia", "swe" => "Svezia", "se" => "Svezia",
    "denmark" => "Danimarca", "danimarca" => "Danimarca", "danmark" => "Danimarca", "den" => "Danimarca", "dnk" => "Danimarca", "dk" => "Danimarca",
    "finland" => "Finlandia", "finlandia" => "Finlandia", "suomi" => "Finlandia", "fin" => "Finlandia", "fi" => "Finlandia",
    "iceland" => "Islanda", "islanda" => "Islanda", "island" => "Islanda", "isl" => "Islanda", "is" => "Islanda",
    # -- North & Central America --
    "unitedstates" => "Stati Uniti", "unitedstatesofamerica" => "Stati Uniti", "statiuniti" => "Stati Uniti",
    "usa" => "Stati Uniti", "us" => "Stati Uniti",
    "canada" => "Canada", "can" => "Canada", "ca" => "Canada",
    "mexico" => "Messico", "messico" => "Messico", "mex" => "Messico", "mx" => "Messico",
    "costarica" => "Costa Rica", "cri" => "Costa Rica", "cr" => "Costa Rica",
    "panama" => "Panama", "pan" => "Panama", "pa" => "Panama",
    "guatemala" => "Guatemala", "gtm" => "Guatemala", "gt" => "Guatemala",
    "honduras" => "Honduras", "hnd" => "Honduras", "hn" => "Honduras",
    # -- South America --
    "brazil" => "Brasile", "brasile" => "Brasile", "brasil" => "Brasile", "bra" => "Brasile", "br" => "Brasile",
    "argentina" => "Argentina", "arg" => "Argentina", "ar" => "Argentina",
    "chile" => "Cile", "cile" => "Cile", "chl" => "Cile", "cl" => "Cile",
    "peru" => "Peru", "per" => "Peru", "pe" => "Peru",
    "colombia" => "Colombia", "col" => "Colombia", "co" => "Colombia",
    "ecuador" => "Ecuador", "ecu" => "Ecuador", "ec" => "Ecuador",
    "uruguay" => "Uruguay", "ury" => "Uruguay", "uy" => "Uruguay",
    "paraguay" => "Paraguay", "par" => "Paraguay", "pry" => "Paraguay", "py" => "Paraguay",
    "bolivia" => "Bolivia", "bol" => "Bolivia", "bo" => "Bolivia",
    "venezuela" => "Venezuela", "ven" => "Venezuela", "ve" => "Venezuela",
    # -- Asia --
    "japan" => "Giappone", "giappone" => "Giappone", "jpn" => "Giappone", "jp" => "Giappone"
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
