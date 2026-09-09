# Preparação dos arquivos locais --------------------------------------------
# Executar da raiz do projeto. Não é executado pelo post.
# A série de 1991/2000 vem do arquivo original; 2010 é compatibilizado com
# 2022 pelo IBGE. Os 81 recortes e suas áreas associadas são os de 2018.

library(dplyr)
library(tidyr)
library(sf)
library(readr)

post_dir <- here::here("insights/posts/2025-06-censo-metro-regions")
archive_dir <- path.expand(
  "~/GitHub/restateinsight/posts/general-posts/2025-06-censo-metro-regions"
)
archive <- qs::qread(file.path(archive_dir, "table.qs"))$metro |>
  select(-tcg, -total_round)

# População municipal -------------------------------------------------------

api_url <- "https://apisidra.ibge.gov.br/values/t/4709/n6/all/v/93,5936,10605/p/2022"
response <- jsonlite::fromJSON(api_url)
cities <- response[-1, ] |>
  transmute(
    code_muni = as.integer(D1C),
    name_muni = sub(" - [A-Z]{2}$", "", D1N),
    state = sub(".* - ", "", D1N),
    variable = D2C,
    value = as.numeric(V)
  ) |>
  pivot_wider(names_from = variable, values_from = value) |>
  transmute(
    code_muni,
    name_muni,
    state,
    pop_2022 = `93`,
    pop_2010 = `93` - `5936`,
    rate_ibge = `10605`
  )
stopifnot(
  nrow(cities) == 5570,
  !anyNA(cities),
  !anyDuplicated(cities$code_muni)
)

# Composição territorial ----------------------------------------------------

shapes <- geobr::read_metro_area(year = 2018, showProgress = FALSE)
membership <- shapes |>
  st_drop_geometry() |>
  filter(!(code_muni == 2705507 & grepl("Zona da Mata", name_metro)))

population <- membership |>
  left_join(cities, by = "code_muni")

totals <- population |>
  summarise(pop_2010 = sum(pop_2010), total = sum(pop_2022), .by = name_metro)

# Os 81 totais de 2022 são distintos e coincidem exatamente com o arquivo.
# Isso permite recuperar seus nomes abreviados sem correspondência aproximada.
stopifnot(!anyDuplicated(totals$total))
keys <- archive |>
  filter(year == 2022) |>
  select(name_metro, total) |>
  left_join(totals, by = "total", suffix = c("", "_official"))
stopifnot(nrow(keys) == 81, !anyNA(keys), !anyDuplicated(keys$total))

metro <- archive |>
  left_join(select(keys, name_metro, pop_2010), by = "name_metro") |>
  mutate(total = if_else(year == 2010, pop_2010, total)) |>
  select(-pop_2010)

membership <- membership |>
  select(code_muni, name_metro, type, subdivision, abbrev_state) |>
  left_join(
    select(keys, name_metro, name_metro_official),
    by = c("name_metro" = "name_metro_official"),
    suffix = c("_official", "")
  )

bh <- shapes |>
  filter(grepl("Belo Horizonte", name_metro)) |>
  select(code_muni, name_muni, subdivision) |>
  st_transform(4326)
stopifnot(nrow(bh) == 50, !any(st_is_empty(bh)))

# Exportação ----------------------------------------------------------------

write_csv(cities, file.path(post_dir, "city-population.csv"))
write_csv(metro, file.path(post_dir, "metro-population.csv"))
write_csv(membership, file.path(post_dir, "metro-membership-2018.csv"))
saveRDS(bh, file.path(post_dir, "belo-horizonte.rds"), compress = "xz")
cli::cli_alert_success(
  "Dados locais preparados para os 81 recortes e 5.570 municípios."
)
