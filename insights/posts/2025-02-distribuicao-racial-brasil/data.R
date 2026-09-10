# Vendoriza a composicao racial por regiao geografica intermediaria.
#
# Fontes:
#   - IBGE/SIDRA, tabela 9605 (Censo 2022, populacao por cor ou raca), no
#     nivel municipal.
#   - IBGE, divisao regional do Brasil em regioes geograficas (2017), que da
#     o municipio -> regiao intermediaria.
#   - geobr::read_intermediate_region(2022) para a malha.
#
# O arquivo gravado guarda a malha simplificada em 2 km com a participacao de
# cada uma das cinco cores ou racas e o grupo majoritario de cada regiao.

library(dplyr)
library(sf)

import::from(stringr, str_sub, str_to_lower)
import::from(sidrar, get_sidra)
import::from(tidyr, pivot_wider, separate_wider_delim)

# Populacao por cor ou raca ----

sidra9605 <- get_sidra(9605, variable = 93, geo = "City")

url_rg <- paste0(
  "https://geoftp.ibge.gov.br/organizacao_do_territorio/divisao_regional/",
  "divisao_regional_do_brasil/divisao_regional_do_brasil_em_regioes_",
  "geograficas_2017/tabelas/regioes_geograficas_composicao_por_municipios_",
  "2017_20180911.xlsx"
)

arquivo_rg <- tempfile(fileext = ".xlsx")
download.file(url_rg, arquivo_rg, quiet = TRUE)

composicao <- readxl::read_excel(arquivo_rg) |>
  rename(code_muni = CD_GEOCODI, code_intermediate = cod_rgint) |>
  mutate(across(starts_with("code"), as.numeric)) |>
  select(code_muni, code_intermediate)

pop <- sidra9605 |>
  as_tibble() |>
  janitor::clean_names() |>
  mutate(
    code_muni = as.numeric(municipio_codigo),
    race = str_to_lower(stringi::stri_trans_general(
      cor_ou_raca,
      "latin-ascii"
    )),
    pop = valor
  ) |>
  filter(race != "total") |>
  select(code_muni, race, pop) |>
  left_join(composicao, by = "code_muni")

stopifnot(!any(is.na(pop$code_intermediate)))

# Participacao por regiao intermediaria ----

racas <- pop |>
  summarise(
    pop = sum(pop, na.rm = TRUE),
    .by = c("code_intermediate", "race")
  ) |>
  mutate(prop = pop / sum(pop), .by = "code_intermediate")

majoritaria <- racas |>
  slice_max(prop, n = 1, by = "code_intermediate") |>
  select(code_intermediate, race, prop, pop_grupo = pop)

largura <- racas |>
  pivot_wider(
    id_cols = "code_intermediate",
    names_from = "race",
    values_from = "prop",
    names_prefix = "prop_"
  )

total <- racas |>
  summarise(pop_total = sum(pop, na.rm = TRUE), .by = "code_intermediate")

tabela <- majoritaria |>
  left_join(largura, by = "code_intermediate") |>
  left_join(total, by = "code_intermediate")

# Malha ----

# A malha traz a Lagoa dos Patos e a Lagoa Mirim como feicoes proprias, sem
# populacao; o mapa nao as usa.
lagoas <- c(4377, 4388)

malha <- geobr::read_intermediate_region(year = 2022, showProgress = FALSE) |>
  filter(!code_intermediate %in% lagoas) |>
  st_make_valid() |>
  st_simplify(dTolerance = 2000, preserveTopology = TRUE)

racial_intermediate <- malha |>
  left_join(tabela, by = "code_intermediate")

stopifnot(
  !any(is.na(racial_intermediate$race)),
  !any(st_is_empty(racial_intermediate))
)

readr::write_rds(
  racial_intermediate,
  here::here(
    "insights/posts/2025-02-distribuicao-racial-brasil/dat_map.rds"
  ),
  compress = "xz"
)
