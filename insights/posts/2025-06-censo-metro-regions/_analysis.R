# Dados e taxas -------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(gt)
library(leaflet)
library(sf)
source(here::here("insights/posts/_ekio-style.R"))

metro <- readr::read_csv("metro-population.csv", show_col_types = FALSE) |>
  arrange(name_metro, year) |>
  mutate(
    tcg = (total / lag(total))^(1 / (year - lag(year))) - 1,
    .by = name_metro
  )

cities <- readr::read_csv("city-population.csv", show_col_types = FALSE) |>
  mutate(
    change = pop_2022 - pop_2010,
    growth = pop_2022 / pop_2010 - 1,
    tcg = (pop_2022 / pop_2010)^(1 / 12) - 1
  )

fmt_number_pt <- function(x, digits = 0) {
  formatC(x, format = "f", digits = digits, big.mark = ".", decimal.mark = ",")
}

metro_rate <- function(name, year_value = 2022) {
  value <- metro |>
    filter(name_metro == name, year == year_value) |>
    pull(tcg)
  stopifnot(length(value) == 1L)
  paste0(fmt_number_pt(value * 100, 2), "%")
}

city_rate <- function(name) {
  value <- cities |> filter(name_muni == name, state == "MG") |> pull(tcg)
  stopifnot(length(value) == 1L)
  paste0(fmt_number_pt(value * 100, 2), "%")
}

# Tabelas -------------------------------------------------------------------

metro_wide <- metro |>
  select(name_metro, code_state, year, total, tcg) |>
  pivot_wider(names_from = year, values_from = c(total, tcg)) |>
  arrange(desc(total_2022))

metro_table <- function(data, national = FALSE) {
  if (national) {
    data <- data |>
      select(
        name_metro,
        total_2000,
        total_2010,
        total_2022,
        tcg_2000,
        tcg_2010,
        tcg_2022
      )
  } else {
    data <- data |> select(name_metro, total_2022, tcg_2000, tcg_2010, tcg_2022)
  }
  data <- data |>
    mutate(
      name_metro = recode(
        trimws(name_metro),
        "AU de Piracicaba-AU- Piracicaba" = "AU de Piracicaba",
        "Belo Horizonte" = "Belo Horizonte + colar"
      ),
      across(starts_with("total"), ~ .x / 1000)
    )
  table <- gt(data) |>
    cols_label(
      name_metro = "Recorte metropolitano",
      total_2022 = "2022",
      tcg_2000 = "1991–2000",
      tcg_2010 = "2000–2010",
      tcg_2022 = "2010–2022"
    ) |>
    tab_spanner("População (mil)", columns = starts_with("total")) |>
    tab_spanner("Crescimento (% ao ano)", columns = starts_with("tcg")) |>
    fmt_number(
      starts_with("total"),
      decimals = 0,
      sep_mark = ".",
      dec_mark = ","
    ) |>
    fmt_percent(starts_with("tcg"), decimals = 2, dec_mark = ",") |>
    data_color(
      columns = starts_with("tcg"),
      palette = c(ekio_site$red, ekio_site$paper, ekio_site$navy),
      domain = c(-1, 1) * max(abs(metro$tcg), na.rm = TRUE)
    ) |>
    tab_source_note(
      "Fonte: IBGE, Censos Demográficos. Recortes de 2018, incluindo áreas associadas. Elaboração: EKIO."
    ) |>
    ekiotable::gt_theme_hokusai(stripe = TRUE) |>
    tab_options(
      table.width = pct(100),
      container.overflow.x = "auto",
      table.font.size = px(13)
    )
  if (national) {
    table <- table |>
      cols_label(total_2000 = "2000", total_2010 = "2010") |>
      tab_header(
        title = "Crescimento demográfico nas regiões metropolitanas",
        subtitle = "Recortes com mais de um milhão de habitantes em 2022."
      )
  }
  table
}

gtable_cities <- metro_table(
  filter(metro_wide, total_2022 > 1e6),
  national = TRUE
)
gtable_pr <- metro_table(filter(metro_wide, code_state == 41))
gtable_sc <- metro_table(filter(metro_wide, code_state == 42))
gtable_rs <- metro_table(filter(metro_wide, code_state == 43))
gtable_se <- metro_table(filter(metro_wide, code_state %in% 31:35))

# Gráficos por porte municipal ----------------------------------------------

size_labels <- c(
  "Menos de 20 mil",
  "20 a 50 mil",
  "50 a 100 mil",
  "100 a 500 mil",
  "500 mil a 1 milhão",
  "Mais de 1 milhão"
)

city_summary <- cities |>
  mutate(
    size = findInterval(pop_2022, c(20000, 50000, 100000, 500000, 1000000))
  ) |>
  summarise(
    share = mean(change > 0) * 100,
    total_growth = sum(change),
    average_growth = weighted.mean(growth, pop_2022) * 100,
    .by = size
  ) |>
  arrange(size) |>
  mutate(label = factor(size_labels[size + 1], levels = rev(size_labels)))

size_chart <- function(
  variable,
  title,
  subtitle,
  divisor = 1,
  suffix = "%",
  digits = 1
) {
  data <- city_summary |>
    mutate(
      value = .data[[variable]] / divisor,
      value_label = paste0(fmt_number_pt(value, digits), suffix)
    )
  ggplot(data, aes(value, label)) +
    geom_col(fill = ekio_site$navy, width = 0.7) +
    geom_text(
      aes(label = value_label),
      hjust = -0.15,
      family = "Lato",
      size = 4
    ) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.25))) +
    labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = NULL,
      caption = "Fonte: IBGE, Censos 2010 e 2022 • EKIO\nPorte municipal em 2022; população de 2010 compatibilizada pelo IBGE."
    ) +
    theme_ekio_site(ticks = "y", grid = "none") +
    theme(
      axis.text.x = element_blank()
    )
}

plots <- list(
  cities = size_chart(
    "share",
    "Cidades de médio e grande porte foram as que mais cresceram",
    "Percentual de municípios com crescimento populacional entre 2010 e 2022."
  ),
  growth = size_chart(
    "average_growth",
    "Crescimento médio por porte municipal",
    "Variação acumulada em 2010–2022, ponderada pela população de 2022."
  ),
  total_growth = size_chart(
    "total_growth",
    "O ganho populacional das cidades por porte populacional",
    "Aumento total da população entre 2010 e 2022, em milhões de habitantes.",
    divisor = 1e6,
    suffix = " mi",
    digits = 2
  )
)

# Mapa de Belo Horizonte e colar metropolitano -------------------------------

bh <- readr::read_rds(here::here(
  "insights/posts/2025-06-censo-metro-regions/belo-horizonte.rds"
)) |>
  left_join(
    select(cities, code_muni, pop_2010, pop_2022, change, tcg),
    by = "code_muni"
  ) |>
  mutate(
    annual_rate = tcg * 100,
    popup = paste0(
      "<strong>",
      name_muni,
      "</strong><br>",
      subdivision,
      "<br>População em 2010: ",
      fmt_number_pt(pop_2010),
      "<br>População em 2022: ",
      fmt_number_pt(pop_2022),
      "<br>Saldo: ",
      fmt_number_pt(change),
      "<br>Crescimento anual: ",
      fmt_number_pt(annual_rate, 2),
      "%"
    )
  )

map_palette <- colorBin(
  palette = c("#B44D47", "#D89D93", "#C8DFE9", "#84B1C8", "#517A90", "#1E3A5F"),
  domain = bh$annual_rate,
  bins = c(-Inf, -0.25, 0, 0.75, 1.5, 2.5, Inf)
)

map <- leaflet(
  bh,
  width = "100%",
  height = 520,
  options = leafletOptions(scrollWheelZoom = FALSE)
) |>
  addTiles() |>
  addPolygons(
    layerId = ~code_muni,
    fillColor = ~ map_palette(annual_rate),
    fillOpacity = 0.8,
    color = ~ ifelse(code_muni == 3106200, "#191A1C", "#FFFFFF"),
    weight = ~ ifelse(code_muni == 3106200, 3, 1),
    label = ~name_muni,
    popup = ~popup,
    highlightOptions = highlightOptions(
      weight = 3,
      color = "#D3742A",
      bringToFront = TRUE
    )
  ) |>
  addLegend(
    colors = map_palette(c(-0.3, -0.1, 0.5, 1, 2, 3)),
    labels = c(
      "Menos de −0,25%",
      "−0,25% a 0%",
      "0% a 0,75%",
      "0,75% a 1,5%",
      "1,5% a 2,5%",
      "2,5% ou mais"
    ),
    title = "Crescimento anual<br>2010–2022",
    position = "bottomright"
  ) |>
  fitBounds(lng1 = -44.8, lat1 = -20.5, lng2 = -43.2, lat2 = -19.1)
