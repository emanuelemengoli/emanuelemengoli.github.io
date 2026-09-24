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
| `duv` | ultra (road & trail alike) | live — official RSS feed of the next ~30 races worldwide, so after filtering to our 5 countries it may return few or none on a given run; deeper per-country coverage (DUV's filterable HTML calendar, confirmed to support `country=ITA/FRA/ESP/SUI/AUT`) is a planned follow-up, not built yet |
| `ffa` | road + trail, France | live — athle.fr's own competition calendar, queried once per level (Régional and above; Départemental alone runs into thousands of small local races and isn't queried); also picks up FFA-licensed French results abroad in our other 4 countries |
| `fitri` | triathlon, Italy | live in principle — fitri.it's calendar is plain server-rendered HTML, but the site was returning a site-wide 503 for the entire time this was built; the scraper is written against a confirmed archived snapshot of the markup and degrades to "0 results, warning logged" if the outage is still ongoing on a given run. **Worth spot-checking the first real run once fitri.it is confirmed back up.** |
| `skyrunning_it` | trail, Italy | live — FISky's own yearly calendar page, one plain HTML table, no pagination |
| `utmb` | trail | live — UTMB World Series' event list; the page is a Next.js app but the full event array (with its own lat/lng already attached) is embedded server-side as JSON, so no HTML scraping is needed. ITRA's own calendar was checked too and ruled out: it loads via client-side JS and sits behind a bot-challenging WAF |
| `switzerland` | road/trail (Swiss Athletics) + triathlon (Swiss Triathlon) | live, first-page-only — neither federation's site exposes a simple paginated URL (PrimeFaces AJAX postbacks / a WordPress calendar plugin's own AJAX), so this is whatever's on page 1 each run. Swiss Athletics' calendar is *every* sanctioned athletics event (track meets, throws, youth meets included), so entries are only kept when the name actually contains a running-race word in German/French/Italian — safer to under-include than to surface a javelin final as a "road race" |
| `austria` | road/trail (ÖLV) + triathlon (ÖTRV) | live, first-page-only — both are plain HTML tables; cancelled (`abgesagt`) and virtual/worldwide entries are filtered out |
| `fftri`, `fidal`, `spain` | triathlon (France), road/trail (Italy), road/trail + triathlon (Spain) | **stubs** — FFTRI's calendar page wasn't inspected yet; FIDAL's is PDF-only per region, not a simple HTML scrape; Spain's federations (RFEA, FETRI) are AJAX-gated (Drupal) / a Blazor single-page app respectively — neither is a plain HTTP scrape. RFEA does have a small server-rendered trail-championships list (`atletismorfea.es/competicion/trail-running`) not wired up yet. Each stub logs why every run, so the gap is always visible rather than silent |

Adding a real source means writing one small `bin/race_sources/<name>.rb` implementing
`RaceSources::Base#fetch` (see `bin/race_sources/aims.rb` or `bin/race_sources/switzerland.rb`
for the shape: fetch, parse, return an Array of Hashes shaped like a `_data/races.yml`
entry — required keys `name`, `date`, `category`, `source`, `source_url`), then swapping
its `Stub` entry in `bin/sync-races`'s `SOURCES` list for the real class. `HtmlFetch.get(url)`
(`bin/lib/html_fetch.rb`) is the standard way to fetch+parse an HTML page — it always tells
Nokogiri the body is UTF-8 explicitly, which matters: several of these sites have no
in-document `<meta charset>` tag, and Nokogiri's own charset-sniffing guesses wrong
(usually Latin-1) even when the bytes are correct UTF-8, silently corrupting every accented
character otherwise.

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
- The only non-stdlib dependency is `nokogiri` (HTML parsing, used by every scraper-based
  adapter) — installed directly (`gem install nokogiri`) rather than a full `bundle install`
  in the scheduled workflow, since nothing here needs the rest of the site's Gemfile.
