library(dplyr)
library(sf)
library(stringr)
library(tidyr)

import::from(cli, cli_alert_success)
import::from(geobr, read_state)
import::from(janitor, clean_names)
import::from(sidrar, get_sidra)

# Faixas etárias quinquenais da tabela 9514, incluindo 100 anos ou mais.
age_codes <- c(93070, 93084:93098, 49108, 49109, 60040, 60041, 6653)

clean_age <- function(data) {
  data |>
    clean_names() |>
    as_tibble() |>
    filter(forma_de_declaracao_da_idade == "Total") |>
    transmute(
      code_state = as.numeric(unidade_da_federacao_codigo),
      sex = sexo,
      age_group = idade,
      age_code = as.numeric(idade_codigo),
      age_min = as.numeric(str_extract(idade, "\\d+")),
      count = valor
    )
}

# Dependência demográfica por UF, Censo 2022 ----
population_state <- get_sidra(
  9514,
  variable = 93,
  geo = "State",
  classific = "c287",
  category = list(age_codes)
) |>
  clean_age() |>
  filter(sex == "Total") |>
  mutate(
    age_class = case_when(
      age_min < 15 ~ "young",
      age_min < 65 ~ "adult",
      TRUE ~ "elder"
    )
  ) |>
  summarise(count = sum(count), .by = c(code_state, age_class)) |>
  pivot_wider(names_from = age_class, values_from = count) |>
  mutate(
    rdi = elder / adult * 100,
    rdj = young / adult * 100,
    rdt = rdi + rdj
  )

state_geometry <- read_state(year = 2022, showProgress = FALSE) |>
  select(
    code_state,
    abbrev_state,
    name_state,
    code_region,
    name_region,
    geometry
  ) |>
  mutate(code_state = as.numeric(code_state))

state_dependency <- left_join(
  state_geometry,
  population_state,
  by = "code_state"
)

# Pirâmides etárias de quatro UFs ----
state_codes <- c(13, 22, 42, 43)

population_pyramid <- lapply(
  state_codes,
  function(state_code) {
    get_sidra(
      9514,
      variable = 93,
      geo = "State",
      geo.filter = list("State" = state_code)
    ) |>
      clean_age() |>
      filter(sex != "Total", age_code %in% age_codes) |>
      mutate(
        sex = factor(
          sex,
          levels = c("Homens", "Mulheres"),
          labels = c("Homens", "Mulheres")
        ),
        age_group = if_else(age_min >= 80, "80 ou mais", age_group),
        age_group = str_remove(age_group, " anos"),
        age_group = factor(age_group),
        age_group = forcats::fct_reorder(age_group, age_min)
      ) |>
      summarise(
        count = sum(count),
        .by = c(code_state, sex, age_group)
      ) |>
      mutate(
        share = count / sum(count) * 100,
        share = if_else(sex == "Homens", -share, share),
        .by = code_state
      )
  }
) |>
  bind_rows() |>
  left_join(
    st_drop_geometry(state_geometry) |>
      select(code_state, name_state, abbrev_state),
    by = "code_state"
  )

# Estimativas e projeções, 2000–2060 ----
clean_projection <- function(data, geography) {
  data |>
    clean_names() |>
    as_tibble() |>
    transmute(
      geography,
      year = as.numeric(ano_2),
      variable = variavel,
      value = valor,
      period = if_else(year <= 2022, "Estimativa", "Projeção")
    )
}

projection_brazil <- get_sidra(
  7360,
  variable = 10609:10612,
  geo = "Brazil"
) |>
  clean_projection("Brasil")

projection_regions <- get_sidra(
  7360,
  variable = 10609:10612,
  geo = "Region"
) |>
  clean_names() |>
  as_tibble() |>
  transmute(
    geography = grande_regiao,
    year = as.numeric(ano_2),
    variable = variavel,
    value = valor,
    period = if_else(year <= 2022, "Estimativa", "Projeção")
  )

projections <- bind_rows(projection_brazil, projection_regions) |>
  filter(year <= 2060)

readr::write_rds(
  list(
    state_dependency = state_dependency,
    population_pyramid = population_pyramid,
    projections = projections
  ),
  here::here(
    "insights/posts/2025-07-demografia-brasil/demografia_brasil.rds"
  ),
  compress = "xz"
)

cli_alert_success("Dados salvos em {.file demografia_brasil.rds}.")
