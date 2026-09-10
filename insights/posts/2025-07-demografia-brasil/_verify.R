library(dplyr)
library(sf)
library(tidyr)

data <- readr::read_rds(here::here(
  "insights/posts/2025-07-demografia-brasil/demografia_brasil.rds"
))

states <- data$state_dependency
pyramids <- data$population_pyramid
projections <- data$projections

testthat::expect_s3_class(states, "sf")
testthat::expect_equal(nrow(states), 27L)
testthat::expect_false(anyNA(states[c("young", "adult", "elder")]))
testthat::expect_equal(states$rdt, states$rdi + states$rdj, tolerance = 1e-10)

pyramid_totals <- pyramids |>
  summarise(total_share = sum(abs(share)), .by = code_state)

testthat::expect_equal(nrow(pyramids), 136L)
testthat::expect_equal(nrow(pyramid_totals), 4L)
testthat::expect_equal(
  pyramid_totals$total_share,
  rep(100, 4),
  tolerance = 1e-8
)

testthat::expect_setequal(
  unique(projections$geography),
  c("Brasil", "Norte", "Nordeste", "Sudeste", "Sul", "Centro-Oeste")
)
testthat::expect_setequal(
  unique(projections$variable),
  c(
    "Razão de dependência total",
    "Razão de dependência de jovens",
    "Razão de dependência de idosos",
    "Índice de envelhecimento"
  )
)
testthat::expect_equal(range(projections$year), c(2000, 2060))
testthat::expect_false(anyNA(projections$value))

brazil_dependency <- projections |>
  filter(
    geography == "Brasil",
    variable == "Razão de dependência total"
  )

minimum <- brazil_dependency |>
  slice_min(value, n = 1, with_ties = FALSE)

testthat::expect_equal(minimum$year, 2017)
testthat::expect_equal(minimum$value, 43.98, tolerance = 0.005)

crossover <- projections |>
  filter(
    variable %in%
      c(
        "Razão de dependência de jovens",
        "Razão de dependência de idosos"
      )
  ) |>
  select(geography, year, variable, value) |>
  pivot_wider(names_from = variable, values_from = value) |>
  filter(
    `Razão de dependência de idosos` >= `Razão de dependência de jovens`
  ) |>
  summarise(year = min(year), .by = geography)

expected_crossover <- tibble::tribble(
  ~geography     , ~year ,
  "Brasil"       ,  2039 ,
  "Norte"        ,  2056 ,
  "Nordeste"     ,  2043 ,
  "Sudeste"      ,  2034 ,
  "Sul"          ,  2033 ,
  "Centro-Oeste" ,  2044
)

testthat::expect_equal(
  arrange(crossover, geography),
  arrange(expected_crossover, geography)
)

cli::cli_alert_success("Os dados e os indicadores do post foram validados.")
