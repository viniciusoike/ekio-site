# Verificação dos dados e das comparações ------------------------------------
# Executar da raiz do projeto: Rscript insights/posts/2025-06-censo-metro-regions/_verify.R

library(dplyr)
library(readr)
library(sf)

post_dir <- here::here("insights/posts/2025-06-censo-metro-regions")
cities <- read_csv(
  file.path(post_dir, "city-population.csv"),
  show_col_types = FALSE
)
metro <- read_csv(
  file.path(post_dir, "metro-population.csv"),
  show_col_types = FALSE
)
membership <- read_csv(
  file.path(post_dir, "metro-membership-2018.csv"),
  show_col_types = FALSE
)
bh <- readRDS(file.path(post_dir, "belo-horizonte.rds"))

stopifnot(
  nrow(cities) == 5570,
  !anyNA(cities),
  !anyDuplicated(cities$code_muni),
  all(cities$pop_2010 > 0),
  sum(cities$pop_2022) == 203080756,
  sum(cities$pop_2010) == 190755799,
  nrow(metro) == 324,
  n_distinct(metro$name_metro) == 81,
  all(count(metro, name_metro, year)$n == 1),
  all(sort(unique(metro$year)) == c(1991, 2000, 2010, 2022)),
  !anyDuplicated(membership$code_muni),
  !anyNA(membership$name_metro)
)

# Comparação independente com a taxa municipal publicada pelo IBGE.
city_rates <- 100 * ((cities$pop_2022 / cities$pop_2010)^(1 / 12) - 1)
stopifnot(max(abs(city_rates - cities$rate_ibge)) < 0.0051)

# As agregações municipais reproduzem todos os totais metropolitanos recentes.
recomputed <- membership |>
  left_join(cities, by = "code_muni") |>
  summarise(
    total_2010 = sum(pop_2010),
    total_2022 = sum(pop_2022),
    .by = name_metro
  ) |>
  tidyr::pivot_longer(
    starts_with("total"),
    names_to = "year",
    values_to = "recomputed"
  ) |>
  mutate(year = as.numeric(sub("total_", "", year)))
comparison <- metro |>
  filter(year %in% c(2010, 2022)) |>
  left_join(recomputed, by = c("name_metro", "year"))
stopifnot(
  !anyNA(comparison$recomputed),
  all(comparison$total == comparison$recomputed)
)

# O mapa usa o mesmo conjunto de 50 municípios que a série de BH.
bh_members <- membership |> filter(name_metro == "Belo Horizonte")
stopifnot(
  nrow(bh) == 50,
  sum(bh$subdivision == "Colar Metropolitano") == 16,
  setequal(bh$code_muni, bh_members$code_muni),
  all(st_is_valid(bh)),
  !any(st_is_empty(bh)),
  st_crs(bh)$epsg == 4326
)

# Verifica o ganho absoluto citado e a liderança entre recortes > 1 milhão.
large_cities <- filter(cities, pop_2022 > 1e6)
stopifnot(sum(large_cities$pop_2022 - large_cities$pop_2010) == 338541)
recent <- comparison |>
  select(name_metro, year, total) |>
  tidyr::pivot_wider(names_from = year, values_from = total) |>
  mutate(rate = (`2022` / `2010`)^(1 / 12) - 1)
leader <- recent |> filter(`2022` > 1e6) |> slice_max(rate, n = 1)
stopifnot(leader$name_metro == "Florianópolis")
cli::cli_alert_success(
  "Dados reconciliados: 81 recortes, 5.570 municípios e mapa de 50 municípios; taxas conferidas com o IBGE."
)
