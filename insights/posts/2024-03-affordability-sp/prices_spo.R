library(realestatebr)
library(dplyr)
library(ggplot2)
library(ekioplot)
import::from(stringr, str_wrap)

igmi <- get_dataset("rppi", "igmi")

subigmi <- igmi |>
  filter(name_muni %in% c("Brasil", "São Paulo"), date <= as.Date("2024-02-01"))

bcb_series <- get_dataset("bcb_series", "primary")

ipca <- bcb_series |>
  filter(name_simplified == "ipca") |>
  select(date, name_simplified, value)

subipca <- ipca |>
  filter(date %in% unique(subigmi$date)) |>
  mutate(
    acum12m = RcppRoll::roll_prodr(1 + value / 100, n = 12) - 1
  )

dat <- bind_rows(subigmi, subipca)

lvls_series <- c("São Paulo", "Brasil", "ipca")
lbls_series <- c("Imóveis (São Paulo)", "Imóveis (Brasil, média)", "IPCA")

dat <- dat |>
  tidyr::unite("name_series", c(name_simplified, name_muni), na.rm = TRUE) |>
  mutate(
    name_series = factor(
      name_series,
      levels = lvls_series,
      labels = lbls_series
    )
  )

subdat <- dat |>
  filter(date >= "2015-01-01")

color_palette <- c(ekio_pal("blue")[c(5, 7)], ekio_pal("accent_blue")[2])
color_palette <- unname(color_palette)

p_acum12m <- ggplot(subdat, aes(date, acum12m)) +
  geom_line(aes(color = name_series), lwd = 0.7) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_percent()) +
  scale_color_manual(
    name = NULL,
    values = color_palette
  ) +
  labs(
    title = "Aceleração do preços dos imóveis após a Pandemia",
    subtitle = str_wrap(
      "Variação acumulada em 12 meses dos preços dos imóveis  residenciais em São Paulo e no Brasil comparados com o IPCA.",
      81
    ),
    caption = "Fonte: IGMI-R (Abecip/FGV); IPCA (IBGE) • EKIO",
    y = NULL,
    x = NULL
  ) +
  theme_ekio()

subdat_index <- dat |>
  filter(date >= as.Date("2020-01-01")) |>
  mutate(chg = if_else(is.na(chg), value / 100, chg)) |>
  mutate(acum = cumprod(1 + chg) - 1, .by = "name_series") |>
  mutate()

aux_label <- subdat_index |>
  slice_max(date, n = 1) |>
  mutate(
    label = scales::percent(acum, decimal.mark = ","),
    pos_x = date + months(4)
  )

p_index <- ggplot(subdat_index, aes(date, acum, group = name_series)) +
  geom_line(aes(color = name_series), lwd = 0.7) +
  geom_label(
    data = aux_label,
    aes(x = pos_x, label = label),
    family = "Lato",
    size = 3,
    hjust = 1,
  ) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(
    labels = scales::label_percent(),
    expand = expansion(c(0, 0.05))
  ) +
  scale_color_manual(
    name = NULL,
    values = color_palette
  ) +
  labs(
    title = "Aumento de quase 80% em SP desde a Pandemia",
    subtitle = str_wrap(
      "Variação acumulada do preços dos imóveis residenciais em São Paulo e no Brasil comparados com o IPCA.",
      81
    ),
    caption = "Fonte: IGMI-R (Abecip/FGV); IPCA (IBGE) • EKIO",
    y = NULL,
    x = NULL
  ) +
  theme_ekio()

ggsave(
  here::here("static/images/insights/2024_03_acum12m.png"),
  p_acum12m,
  width = 6,
  height = 4,
  dpi = 300
)

ggsave(
  here::here("static/images/insights/2024_03_index.png"),
  p_index,
  width = 6,
  height = 4,
  dpi = 300
)
