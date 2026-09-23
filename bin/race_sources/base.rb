# frozen_string_literal: true

module RaceSources
  # Common contract every adapter follows. #fetch must never raise past the caller — a
  # network hiccup, a blocked request, or a page that changed shape should degrade to
  # "this source found nothing this run", not crash the whole sync. Adapters do their own
  # rescuing; bin/sync-races adds a second safety net on top of that, so one broken/blocked
  # source (several of these are explicitly unofficial/fragile by design) can never take
  # the rest of the run down with it.
  class Base
    # Short, stable identifier stored on every entry as `source` — used for traceability
    # (which adapter produced/last-confirmed a race) and for `--source=NAME` filtering.
    def name
      raise NotImplementedError
    end

    # Returns an Array of Hashes already shaped like a _data/races.yml entry (string keys;
    # unknown/not-yet-determined fields simply absent, never nil-padded). Required per
    # entry: "name", "date" ("YYYY-MM-DD"), "category", "source", "source_url".
    def fetch
      raise NotImplementedError
    end
  end

  # A source that isn't wired up yet. Keeps the adapter list complete and self-documenting
  # (every planned source is visible in bin/sync-races's output) without a bespoke empty
  # class per pending source.
  class Stub < Base
    def initialize(name, note:)
      @name = name
      @note = note
    end

    attr_reader :name

    def fetch
      warn "  ~ #{name}: #{@note} (not implemented yet, skipping)"
      []
    end
  end
end
