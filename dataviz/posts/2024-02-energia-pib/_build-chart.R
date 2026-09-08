# Historical energy and activity comparison ----------------------------------
# Run from this post's directory. Uses the saved SGS snapshot; no API calls.
library(dplyr)
library(ggplot2)
library(ekioplot)
library(lubridate)

source("../../../insights/posts/_ekio-style.R")

raw <- readr::read_csv("series-source.csv", show_col_types = FALSE)
stopifnot(
  !anyNA(raw),
  all(raw$value > 0),
  !anyDuplicated(raw[c("series", "date")])
)
stopifnot(all(raw$date < as.Date("2024-01-01")))

# Extract the monthly energy trend -------------------------------------------
energy <- raw |>
  filter(series == "energia") |>
  arrange(date)
expected_dates <- seq(min(energy$date), max(energy$date), by = "month")
stopifnot(identical(energy$date, expected_dates))

energy_ts <- ts(log(energy$value), start = c(2002, 1), frequency = 12)
decomposition <- forecast::mstl(energy_ts, s.window = 51, robust = TRUE)
energy$value <- exp(decomposition[, "Trend"])

series <- bind_rows(energy, filter(raw, series != "energia"))
baselines <- series |>
  filter(format(date, "%Y") == "2005") |>
  summarise(baseline = mean(value), .by = series)

indexed <- series |>
  left_join(baselines, by = "series") |>
  mutate(index = value / baseline * 100)
base_check <- indexed |>
  filter(format(date, "%Y") == "2005") |>
  summarise(value = mean(index), .by = series)
stopifnot(all(abs(base_check$value - 100) < 1e-8))

# Place quarterly GDP in the final month of its reference quarter.
indexed <- indexed |>
  mutate(date = if_else(series == "pib", date + months(2), date)) |>
  filter(date >= as.Date("2003-01-01"))

endpoints <- indexed |>
  slice_max(date, n = 1, by = series) |>
  mutate(
    label = recode(
      series,
      energia = "Eletricidade",
      pib = "PIB",
      ibc = "IBC-Br"
    )
  )
stopifnot(all(endpoints$date == as.Date("2023-12-01")))
readr::write_csv(indexed, "series-chart.csv")

# Direct labels keep the plot readable without a separate legend -------------
colors <- c(
  energia = ekio_site$orange,
  pib = ekio_site$teal,
  ibc = ekio_site$navy
)
chart <- ggplot(indexed, aes(date, index, color = series)) +
  geom_hline(yintercept = 100, color = ekio_site$rule_strong, linewidth = 0.4) +
  geom_vline(
    xintercept = as.Date("2014-01-01"),
    color = ekio_site$rule_strong,
    linewidth = 0.4,
    linetype = "dashed"
  ) +
  geom_line(linewidth = 1.1) +
  geom_point(data = endpoints, size = 2) +
  geom_text(
    data = endpoints,
    aes(label = label),
    hjust = 0,
    nudge_x = 100,
    family = "Lato",
    size = 4.6,
    fontface = "bold"
  ) +
  annotate(
    "text",
    x = as.Date("2014-01-01"),
    y = 94,
    label = "2014",
    hjust = -0.2,
    family = "Lato",
    size = 4,
    color = ekio_site$ink_500
  ) +
  scale_color_manual(values = colors, guide = "none") +
  scale_x_date(
    breaks = as.Date(c(
      "2003-01-01",
      "2008-01-01",
      "2013-01-01",
      "2018-01-01",
      "2023-01-01"
    )),
    date_labels = "%Y",
    expand = expansion(mult = c(0.01, 0.2))
  ) +
  scale_y_continuous(breaks = seq(100, 160, 20)) +
  labs(
    title = "Eletricidade e atividade econômica",
    subtitle = "Brasil, 2003–2023 • Índices: média de 2005 = 100",
    x = NULL,
    y = NULL,
    caption = "Eletricidade: tendência STL. PIB e IBC-Br: ajuste sazonal.\nFonte: Banco Central (SGS). Reconstrução: EKIO, set/2026."
  ) +
  theme_ekio_site(base_size = 14) +
  theme(
    plot.margin = margin(16, 16, 12, 12),
    axis.text = element_text(size = 12),
    plot.subtitle = element_text(size = 13),
    plot.caption = element_text(size = 10, hjust = 0)
  )

ggsave(
  "energia-pib.png",
  chart,
  width = 9.4,
  height = 5.8,
  dpi = 200,
  device = ragg::agg_png
)
cli::cli_alert_success(
  "Chart rebuilt from saved data; dates, baseline and endpoints checked."
)
print(endpoints |> select(series, date, index))
