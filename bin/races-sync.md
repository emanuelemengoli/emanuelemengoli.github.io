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

Deliberately narrow for now, per the owner: the named French/Italian federations, the
trail/skyrunning-specific sources, and the international brand calendars explicitly
asked for — not the broader multi-country breadth an earlier pass at this built. Spain,
Switzerland and Austria are explicit stubs rather than populated, and AIMS/DUV (both
working, both previously active) are simply not required by `bin/sync-races` right now —
`aims.rb`/`duv.rb` are still on disk if that breadth comes back into scope.

| Source | Category | Status |
|---|---|---|
| `ffa` | road + trail, France | live — athle.fr's own competition calendar, queried once per level (Régional and above; Départemental alone runs into thousands of small local races and isn't queried); also picks up FFA-licensed French results abroad in Italy/Spain/Switzerland/Austria |
| `fitri` | triathlon, Italy | live in principle — fitri.it's calendar is plain server-rendered HTML, but the site was returning a site-wide 503 for the entire time this was built; the scraper is written against a confirmed archived snapshot of the markup and degrades to "0 results, warning logged" if the outage is still ongoing on a given run. **Worth spot-checking the first real run once fitri.it is confirmed back up.** |
| `skyrunning_it` | skyrun, Italy | live — FISky's own yearly calendar page, one plain HTML table, no pagination |
| `utmb` | trail | live — UTMB World Series' event list; the page is a Next.js app but the full event array (with its own lat/lng already attached) is embedded server-side as JSON, so no HTML scraping is needed |
| `fftri` | triathlon, France | **stub** — fftri.com's national-championship-stages calendar turned out to be poor-quality on inspection: a Google-Sheets-pasted table with merged header cells across race "stages," dates given without a year per row, and most of the year values actually present in the page are stale (2018), not current. Scraping it as-is risked silently attaching the wrong year to a race, so it was left a stub rather than shipped with wrong dates |
| `fidal` | road + trail, Italy | **stub** — fidal.it's `calendario.php` takes a `livello`/`regione`/`anno` query like athle.fr's, but the real parameter values aren't documented anywhere discoverable (guesses return the empty search form, not results); its regional pages elsewhere on the site are PDF-only |
| `itra` | trail | **stub** — itra.run's calendar loads via client-side JS (empty on initial load) and the site sits behind a bot-challenging AWS WAF that starts returning empty "challenge" responses after a few plain requests. UTMB's own World Series list (`utmb` above) is the trail source instead |
| `ironman` | triathlon | **stub** — `www.ironman.com` is Cloudflare-blocked outright; the bare `ironman.com` domain isn't challenged the same way and does serve a real `/races` page, but the actual listing renders via a Drupal AJAX call, not present in the plain HTML response (same blocker pattern as `spain`'s RFEA, below) |
| `spain`, `switzerland`, `austria` | — | **stubs, not in scope for now** — Switzerland and Austria had working scrapers in an earlier pass (Swiss Athletics + Swiss Triathlon; ÖLV + ÖTRV — both plain HTML tables) that were removed when the owner narrowed scope; Spain's federations (RFEA, FETRI) were checked and are AJAX-gated (Drupal) / a Blazor single-page app respectively. If any of the three come back into scope, re-identify (or, for CH/AT, recover from git history) their sources |

Adding a real source means writing one small `bin/race_sources/<name>.rb` implementing
`RaceSources::Base#fetch` (see `bin/race_sources/ffa.rb` for the shape: fetch, parse,
return an Array of Hashes shaped like a `_data/races.yml` entry — required keys `name`,
`date`, `category`, `source`, `source_url`), then swapping its `Stub` entry in
`bin/sync-races`'s `SOURCES` list for the real class. `HtmlFetch.get(url)`
(`bin/lib/html_fetch.rb`) is the standard way to fetch+parse an HTML page — it always tells
Nokogiri the body is UTF-8 explicitly, which matters: several of these sites have no
in-document `<meta charset>` tag, and Nokogiri's own charset-sniffing guesses wrong
(usually Latin-1) even when the bytes are correct UTF-8, silently corrupting every accented
character otherwise.

## Everyday use

```sh
ruby bin/sync-races                   # fetch every source, merge into _data/races.yml
ruby bin/sync-races --source=ffa,utmb # just these sources, for debugging one adapter
ruby bin/sync-races --sort            # also re-order soonest-first
ruby bin/sync-races --dry-run         # show what would change, write nothing
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
