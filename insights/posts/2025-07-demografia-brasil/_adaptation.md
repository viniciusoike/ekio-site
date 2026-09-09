# Adaptation notes

Source: `~/GitHub/restateinsight/posts/general-posts/2025-07-demografia-brasil/`.
Adapted on 2026-09-09. The migration keeps the original date and central
argument, but reorganizes repeated sections and updates the analysis to the
IBGE's 2024 population projections.

## Data and reproduction

- `data.R` downloads the age distributions from SIDRA table 9514 and the
  demographic estimates and projections from table 7360. It also obtains 2022
  state boundaries from `geobr`.
- `demografia_brasil.rds` contains only the three inputs used by the post: state
  dependency ratios, four state age pyramids and projections for Brazil and its
  five regions. The 0.9 MB file replaces the archive's 18 MB bundle of serialized
  plots, tables and an unused Leaflet widget.
- `_verify.R` checks geographic and temporal coverage, ratio identities, age
  shares, the minimum national dependency ratio and the projected crossover
  between young and old-age dependency.
- Rendering uses the local RDS and does not require network access. Run `data.R`
  only to refresh the source snapshot.

## Necessary corrections

- The aging-index equation in the archive had its numerator and denominator
  reversed. The adapted text uses people aged 65 or older per 100 people aged 0
  to 14.
- The archive described the denominator of the demographic dependency ratio as
  the economically active population. It is the potentially active population,
  aged 15 to 64, regardless of labor-force participation.
- The projection period now begins in 2023, consistent with the IBGE's 2024
  revision. The archive marked 2022 as projected.
- National and regional values are calculated from the current SIDRA table. The
  national dependency ratio reaches its minimum in 2017 and old-age dependency
  overtakes youth dependency in 2039.
- Typos, duplicated headings, obsolete Restate Insight links and unfinished
  transitions were removed or rewritten.

## Presentation

The article retains the generational and municipal-aging figures from existing
EKIO posts as local assets. The broken `/_site/` references are gone. The new
dependency chart, table, bivariate state map and age pyramids use the shared EKIO
style helpers and include Portuguese labels and detailed alternative text.
