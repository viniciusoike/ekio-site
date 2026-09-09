# Adaptation notes

Source: `~/GitHub/restateinsight/posts/general-posts/2025-06-censo-metro-regions/`.
Adapted on 2026-09-09. The original title, section order and narrative were
preserved; edits address grammar, incomplete sentences, factual errors and site
integration. The original date identifies the archive article, not a new census.

## Data and reproduction

- `data.R` prepares the four local input files. Run it from the repository root;
  it requires the original `table.qs`, network access and `geobr`/`qs`.
- `_analysis.R` builds all outputs from local inputs. Rendering requires neither
  the archive nor network data downloads. The interactive basemap uses external
  OpenStreetMap tiles in the browser.
- `_verify.R` checks the municipal rates against the independently published IBGE
  rates, reaggregates all 81 recent metropolitan totals, and checks map coverage.
- `city-population.csv`: SIDRA table 4709, downloaded 2026-09-09. Variables 93,
  5936 and 10605. The 2010 population is 2022 population minus the IBGE's
  territorially compatible absolute change. API:
  <https://apisidra.ibge.gov.br/values/t/4709/n6/all/v/93,5936,10605/p/2022>.
- `metro-population.csv`: unrounded 1991/2000 totals from the archived table;
  2010 totals recomputed from compatible municipal populations; 2022 totals
  independently reconciled with SIDRA. All 81 archived 2022 totals match the
  2018 geographic definitions exactly. Earlier municipal boundaries remain a
  limitation, stated in the article.
- `metro-membership-2018.csv`: membership from `geobr::read_metro_area(2018)`,
  including associated areas. Murici is assigned only to Maceió, matching the
  original treatment. The file includes original and abbreviated unit names.
- `belo-horizonte.rds`: geometry and identifiers for 34 RM municipalities and
  16 colar municipalities from the same base. Only these columns are retained;
  populations and rates are joined when the post renders.

## Necessary corrections

- Annual metropolitan rates now use 9, 10 and 12 years, removing the original
  extra year. Inline rates and tables share the same calculations.
- Porto Velho and Macapá had misplaced decimal places in the prose; their
  corrected rates are approximately 0.62% and 0.86% annually. This requires
  replacing the claim that both virtually stagnated.
- Northeast-wide annual growth is 0.24%, not 0.35%.
- Municipal comparisons use IBGE-compatible 2010 boundaries. The gain in cities
  above one million changes from roughly 351,000 to 339,000. The 14.3% measure
  is explicitly identified as population-weighted mean cumulative growth.
- Goiânia's 2022 population rounds to 2.55 million, not 2.56 million.
- Belo Horizonte includes the colar in the original data and map; this is now
  explicit. Its municipal population in 2010 rounds to 2.376 million.
- The urban-policy explanation is attributed to Thiago Jardim. A brief footnote
  distinguishes that interpretation from what census population changes alone
  establish. Nova Lima is described as one of the fastest-growing municipalities,
  rather than as the largest recipient of an unmeasured migration flow.
- The unfinished medium-city paragraph is completed using the existing comparison.

## Presentation

Five tables, three charts, the interactive map, and the original regional/chart
tabsets are retained. Outputs use the shared EKIO helpers. The cover reuses the
existing `insight-metropolitan-drift.webp`; the archive's serialized plot objects
and legacy table theme are unnecessary. Frozen output includes the Leaflet assets
needed for a site build without executing R.
