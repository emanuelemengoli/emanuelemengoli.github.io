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
- **Country scope** (`bin/lib/countries.rb`): Italy, France, Spain, Switzerland, Austria,
  Greece, Portugal, the UK, the Netherlands, the Nordic countries, North & Central
  America, South America, and Japan — the owner's explicit list, not simply "every
  country a source happens to cover." An entry from outside this list is dropped by the
  adapter that found it (`Countries.lookup`/`.detect` return `nil`), the same as any
  other out-of-scope result.
- **`road`-category distance filter**: half marathon (21.1km) and up only, with a
  standing exception for 15km races — a road race whose distance can't be determined at
  all is dropped, not kept (`road_length_ok?` in `bin/sync-races`). Deliberate: several
  sources (calendariopodismo.it above all) otherwise return a flood of short local
  races. Trail/skyrun/ultra/triathlon aren't distance-filtered.
- **`wine` tag**: any entry whose name/region matches a wine-region/event keyword
  (`bin/lib/wine_tag.rb` — "Médoc", "Chianti", "Rioja", "vigneto", ...) gets tagged
  `tags: [wine]`, applied centrally to every source's output, not per-adapter. Real
  example already in the data: the Marathon des Châteaux du Médoc pairs a marathon with
  wine tastings at (almost) every kilometre through Bordeaux's vineyards.

## One-time repo setup

**Settings → Actions → General → "Allow GitHub Actions to create and approve pull
requests"** must be turned on, or the scheduled workflow can fetch data but can't open a
PR with it. This can't be set from the workflow file itself.

## Sources (`bin/race_sources/`)

| Source | Category | Status |
|---|---|---|
| `ffa` | road + trail, France | live — athle.fr's own competition calendar, queried once per level (Régional and above; Départemental alone runs into thousands of small local races and isn't queried) |
| `fftri` | triathlon, international | live — fftri.com's *international* calendar pages (Monde / Europe — its national-championship-stages page is separately stale/undated and isn't used). Plain prose, not a table: a best-effort line parser, skipping any line that doesn't match the expected "date : text (COUNTRY)" shape |
| `fitri` | triathlon, Italy | live in principle — fitri.it's calendar is plain server-rendered HTML, but the site was returning a site-wide 503 for the entire time this was built; the scraper is written against a confirmed archived snapshot of the markup and degrades to "0 results, warning logged" if the outage is still ongoing on a given run. **Worth spot-checking once fitri.it is confirmed back up.** |
| `skyrunning_it` | skyrun, Italy | live — FISky's own yearly calendar page, one plain HTML table, no pagination |
| `calendariopodismo` | road + trail, Italy | live — a dedicated Italian race calendar, one page per region (all 20). Genuinely good data: ISO dates and (usually) lat/lng already on each card, no geocoding needed for most entries |
| `utmb` | trail | live — UTMB World Series' event list; the page is a Next.js app but the full event array (with its own lat/lng already attached) is embedded server-side as JSON |
| `ironman` | triathlon, worldwide | live — ironman.com's own race listing is Drupal-AJAX-gated (not present in the plain page HTML) and `www.ironman.com` is separately Cloudflare-blocked outright; cracked by replaying the bare `ironman.com` domain's `/views/ajax` call directly (see the adapter's header comment for the mechanics) |
| `fidal` | road + trail, Italy | **stub** — fidal.it's `calendario.php` takes a `livello`/`regione`/`anno` query like athle.fr's, but the real parameter values aren't documented anywhere discoverable (guesses return the empty search form, not results); its regional pages elsewhere on the site are PDF-only |
| `itra` | trail | **stub** — itra.run's calendar loads via client-side JS (empty on initial load) and the site sits behind a bot-challenging AWS WAF, confirmed twice including a real POST-based search attempt (session cookie + CSRF token) that was challenged the same way. UTMB's own World Series list (`utmb` above) is the trail source instead |
| `spain`, `switzerland`, `austria` | — | **stubs, not in scope for now** (these are *country-specific* federation stubs, independent of the worldwide country list above — FFA/FFTRI/UTMB/Ironman already surface whatever they each cover in Spain/Switzerland/Austria) — RFEA/RFETRI are AJAX-gated (Drupal) / a Blazor SPA; Swiss and Austrian federations had working scrapers in an earlier pass, removed when the owner narrowed scope. Re-identify (or, for CH/AT, recover from git history) if these come back into scope |

`aims.rb`/`duv.rb` (AIMS' official road-race iCalendar feed; DUV's ultramarathon
database) are still on disk, fully working, just not required by `bin/sync-races` right
now — the owner asked for a narrower source list. Re-add to `SOURCES` if that breadth is
wanted back, particularly `duv` for real ultra coverage (there is currently no ultra
source active).

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
