# Vendoriza o índice de envelhecimento municipal do arquivo restateinsight.
#
# Fonte: restateinsight/static/data/census_aging_index_city.qs (14 MB), montado
# a partir dos Censos Demográficos do IBGE de 1991, 2000, 2010 e 2022 com as
# malhas municipais de 2022. O índice é a razão entre a população de 65 anos ou
# mais e a população de até 14 anos, por 100.
#
# O arquivo aqui guarda as colunas usadas no post e a geometria simplificada em
# 500 m, o que leva os 5.570 municípios de 14 MB para 2,7 MB.

library(dplyr)
library(sf)

origem <- "~/GitHub/restateinsight/static/data/census_aging_index_city.qs"

cities_age <- qs::qread(path.expand(origem)) |>
  select(
    code_muni,
    name_muni,
    abbrev_state,
    name_region,
    starts_with("age_index")
  ) |>
  st_make_valid() |>
  st_simplify(dTolerance = 500, preserveTopology = TRUE)

stopifnot(!any(st_is_empty(cities_age)))

saveRDS(
  cities_age,
  here::here(
    "insights/posts/2024-04-envelhecimento-brasil/aging_index_city.rds"
  ),
  compress = "xz"
)
