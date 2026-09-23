# Auto-syncing the races section

`_data/races.yml` drives the races section on `/le-mie-passioni/`. Unlike the wine map,
there is nothing to fill in by hand: `.github/workflows/sync-races.yml` runs
`ruby bin/sync-races` on the 1st of every month, re-fetching every source under
`bin/race_sources/` and opening a **pull request** with the result. Reviewing and merging
that PR is the only manual step — merging it triggers the normal deploy workflow, same as
any other push.

- **Merge / upsert** on *name + date + country*: a race is one edition of an event, so the
  same race announced for a later year becomes a *new* entry rather than overwriting the
  earlier one — both stay listed until their own date passes.
- **Rolling feed, not an archive**: every run drops any entry whose date is more than 7
  days in the past, so the file only ever holds upcoming races. There's no need to ever
  manually clean it out.
- New entries are **geocoded** from `name, region, country` via OpenStreetMap Nominatim
  (cached in `bin/.races_geocache.json`, gitignored like the wine cache). Sparse source
  data (a country with no city given) can only geocode to that country's centroid — a
  real but low-priority accuracy gap, not a bug.
- Every source is **best-effort and independent**: if one is blocked, changes shape, or
  errors out, `bin/sync-races` logs a warning and carries on with the rest — one bad
  source can never fail the whole run or block the others' entries from updating.

## One-time repo setup

**Settings → Actions → General → "Allow GitHub Actions to create and approve pull
requests"** must be turned on, or the scheduled workflow can fetch data but can't open a
PR with it. This can't be set from the workflow file itself.

## Sources (`bin/race_sources/`)

| Source | Category | Status |
|---|---|---|
| `aims` | road | live — official iCalendar feed, `aims-worldrunning.org/events.ics` |
| `duv` | ultra (road & trail alike) | live — official RSS feed of the next ~30 races worldwide, so after filtering to our 5 countries it may return few or none on a given run; deeper per-country coverage (DUV's filterable HTML calendar) is a planned follow-up, not built yet |
| `ffa`, `fftri`, `fidal`, `fitri`, `skyrunning_it`, `utmb_itra`, `spain`, `switzerland`, `austria` | trail / triathlon / road, by country | **stubs** — return no data yet; each logs why (missing URL, scraper not built, or a JS-rendered page that needs a different approach) every run, so the gap is always visible rather than silent |

Adding a real source means writing one small `bin/race_sources/<name>.rb` implementing
`RaceSources::Base#fetch` (see `bin/race_sources/aims.rb` or `duv.rb` for the shape:
fetch, parse, return an Array of Hashes shaped like a `_data/races.yml` entry — required
keys `name`, `date`, `category`, `source`, `source_url`), then swapping its `Stub` entry
in `bin/sync-races`'s `SOURCES` list for the real class.

## Everyday use

```sh
ruby bin/sync-races                    # fetch every source, merge into _data/races.yml
ruby bin/sync-races --source=aims,duv  # just these sources, for debugging one adapter
ruby bin/sync-races --sort             # also re-order soonest-first
ruby bin/sync-races --dry-run          # show what would change, write nothing
git diff _data/races.yml
```

The scheduled workflow calls the same script; there's no separate "production" path to
keep in sync.

## Notes & limits

- No source here publishes entry fees, so `price` stays blank on every auto-synced entry;
  it exists in the schema for a possible future manual-override file, not populated today.
- `distance_km`/`elevation_gain_m`/`difficulty` are best-effort: populated when a source
  states them, left blank otherwise — a blank value never excludes a race from a search.
- Ruby's `csv`/`rexml` are stdlib; `bin/sync-races` and every adapter use only the Ruby
  standard library (no gems), so no `bundle install` step is needed to run it, locally or
  in the scheduled workflow.
