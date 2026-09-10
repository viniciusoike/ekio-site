# Dependencies ----

library(ggplot2)
library(dplyr)
library(lubridate)

source(here::here("insights/posts/_ekio-style.R"))


# Data ----

post_date <- as.Date("2026-01-05")
data_end <- as.Date("2025-11-01")

ipca <- GetBCBData::gbcbd_get_series(
  433,
  first.date = as.Date("1980-01-01")
)

ipca <- ipca |>
  rename(date = ref.date) |>
  select(date, value) |>
  dplyr::filter(date <= data_end)

date_last_ipca <- max(ipca$date)
date_last_ipca_fmt <- format(date_last_ipca, "%b/%Y")
plot_caption <- stringr::str_glue(
  "Fonte: IBGE • Elaboração: EKIO • Última observação disponível {date_last_ipca_fmt}"
)

stopifnot(date_last_ipca == data_end, data_end < post_date)


# Shared chart data ----

presidents <- tidyr::tribble(
  ~start       , ~end         , ~name           ,
  "1979-12-01" , "1985-02-01" , "Figueiredo"    ,
  "1985-03-01" , "1989-12-01" , "Sarney"        ,
  "1990-01-01" , "1992-12-01" , "Collor"        ,
  "1993-01-01" , "1994-12-01" , "Itamar Franco" ,
  "1995-01-01" , "2001-12-01" , "FHC"           ,
  "2002-01-01" , "2008-12-01" , "Lula"          ,
  "2009-01-01" , "2016-06-01" , "Dilma"         ,
  "2016-07-01" , "2017-12-01" , "Temer"         ,
  "2018-01-01" , "2022-12-01" , "Bolsonaro"     ,
  "2023-01-01" , "2025-11-01" , "Lula"
)

presidents <- presidents |>
  dplyr::mutate(
    start = as.Date(start),
    end = as.Date(end),
    x_label = dplyr::if_else(
      name == "Collor",
      start + months(6),
      start + months(3)
    )
  )

president_colors <- c(
  "Figueiredo" = ekio_pigment$air_force_blue,
  "Sarney" = ekio_pal("green")[2],
  "Collor" = ekio_pal("purple")[3],
  "Itamar Franco" = ekio_pigment$alabaster,
  # "FHC" = ekio_pigment$baltic_blue,
  "FHC" = ekio_pal("blue")[2],
  "Lula" = ekio_pal("red")[2],
  "Dilma" = ekio_pal("orange")[2],
  "Temer" = ekio_pal("green")[2],
  "Bolsonaro" = ekio_pal("stone")[3]
)

chart_theme <- theme_ekio_site(font_text = "Host Grotesk", base_size = 10) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(
      color = ekio_surface$ink_300,
      linetype = 2
    ),
    # plot.subtitle = element_text(family = "Lato"),
    # plot.caption = element_text(family = "Lato"),
    axis.title.y = element_text(angle = 0, vjust = 1)
  )


# Complete history ----

historic_events <- tidyr::tribble(
  ~date        , ~event                              , ~date_label , ~yseg , ~date_nudge ,
  "1980-01-01" , "Delfim + crise do petróleo"        , "DEZ 1979"  ,  -8   ,           0 ,
  "1983-02-01" , "Delfim (2º)"                       , "FEV 1983"  ,  -9.5 ,           0 ,
  "1985-05-01" , "Fim do regime militar"             , "MAR 1985"  ,  25   ,           0 ,
  "1986-04-01" , "Plano Cruzado"                     , "FEV 1986"  ,  -9.5 ,          -3 ,
  "1987-08-01" , "Plano Bresser"                     , "JUN 1987"  ,  45   ,           0 ,
  "1989-03-01" , "Plano Verão"                       , "JAN 1989"  ,  -9.5 ,          -3 ,
  "1990-05-01" , "Plano Collor"                      , "MAR 1990"  ,  -9.5 ,           0 ,
  "1991-04-01" , "Plano Collor II"                   , "JAN 1991"  ,  55   ,          -3 ,
  "1993-01-01" , "Impeachment de Collor"             , "DEZ 1992"  ,  -9.5 ,           0 ,
  "1994-08-01" , "Plano Real"                        , "JUL 1994"  ,  65   ,          -3 ,
  "1999-01-01" , "Câmbio flutuante"                  , "JAN 1999"  ,  10   ,           0 ,
  "1999-08-01" , "Metas de inflação"                 , "JUN 1999"  ,  -9.5 ,          -3 ,
  "2000-07-01" , "Novo regime fiscal"                , "MAI 2000"  ,  15   ,           0 ,
  "2002-11-01" , "Argentina + crise de confiança"    , "2002"      ,  -9.5 ,           0 ,
  "2008-04-01" , "Brasil obtém grau de investimento" , NA          ,  -8   ,           0 ,
  "2008-07-01" , "Crise financeira global"           , "2008"      ,  10   ,           0 ,
  "2015-09-01" , "Brasil perde grau de investimento" , "2015"      ,  10   ,          -3 ,
  "2016-08-01" , "Impeachment de Dilma"              , "AGO 2016"  ,  -9.5 ,           0 ,
  "2020-03-01" , "Covid-19"                          , "MAR 2020"  , -10   ,          -3 ,
  "2021-03-01" , "Autonomia do Banco Central"        , "FEV 2021"  ,  10   ,           0 ,
  "2025-01-01" , "Meta contínua de inflação"         , "JAN 2025"  ,  10   ,           0
)

historic_events <- historic_events |>
  dplyr::mutate(
    date = as.Date(date),
    event_label = case_when(
      event == "Plano Verão" ~ "Plano\nVerão",
      .default = stringr::str_wrap(event, width = 11)
    ),
    line_count = stringr::str_count(event_label, "\\n"),
    text_offset = 1.5 + 1.5 * line_count,
    ytext = dplyr::if_else(yseg < 0, yseg - text_offset, yseg + text_offset),
    y_date_label = -3.5 + date_nudge
  )

historic_events <- dplyr::left_join(historic_events, ipca, by = "date")

accumulated <- ipca |>
  dplyr::mutate(
    segment = dplyr::if_else(
      date < as.Date("1995-01-01"),
      "Pré-Real",
      "Pós-Real"
    )
  ) |>
  dplyr::summarise(
    accumulated = (prod(1 + value / 100) - 1) * 100,
    start = min(date),
    end = max(date),
    .by = segment
  ) |>
  dplyr::mutate(
    accumulated_label = scales::label_number(
      accuracy = 0.01,
      big.mark = ".",
      decimal.mark = ","
    )(accumulated),
    accumulated_label = stringr::str_glue(
      "Inflação acumulada = {accumulated_label}%"
    ),
    midpoint = start + days(floor((end - start) / 2))
  )

plot_inflation <- ggplot() +
  geom_rect(
    data = presidents,
    aes(xmin = start, xmax = end, ymin = 0, ymax = 82, fill = name),
    alpha = 0.55
  ) +
  geom_area(
    data = ipca,
    aes(x = date, y = value),
    fill = ekio_site$ink_600
  ) +
  geom_segment(
    data = historic_events,
    aes(x = date, xend = date, y = yseg, yend = value),
    color = ekio_site$red
  ) +
  geom_segment(
    data = historic_events,
    aes(x = date, xend = date + months(12), y = yseg, yend = yseg),
    color = ekio_site$red
  ) +
  geom_point(
    data = historic_events,
    aes(x = date, y = value),
    shape = 21,
    fill = ekio_site$red,
    color = ekio_surface$paper
  ) +
  geom_label(
    data = dplyr::filter(historic_events, !is.na(date_label)),
    aes(x = date, y = y_date_label, label = date_label),
    family = "Host Grotesk",
    label.r = grid::unit(0, "pt"),
    label.padding = grid::unit(0.1, "line"),
    size = 3,
    fill = ekio_site$ink,
    color = ekio_surface$paper
  ) +
  geom_text(
    data = historic_events,
    aes(x = date, y = ytext, label = event_label),
    family = "Host Grotesk",
    size = 3,
    hjust = 0,
    lineheight = 0.8,
    color = ekio_site$ink
  ) +
  geom_segment(
    data = accumulated,
    aes(x = start, xend = end, y = 85, yend = 85, group = segment),
    arrow = arrow(length = grid::unit(0.3, "cm"), ends = "both")
  ) +
  geom_text(
    data = accumulated,
    aes(x = midpoint, y = 88, label = accumulated_label),
    family = "Host Grotesk",
    fontface = "bold",
    color = ekio_site$red
  ) +
  geom_text(
    data = presidents,
    aes(x = x_label, y = 40.5, label = name),
    angle = 90,
    hjust = 0,
    family = "Host Grotesk",
    color = ekio_site$ink_700
  ) +
  geom_hline(yintercept = 0, color = ekio_site$ink) +
  scale_x_date(
    breaks = seq(as.Date("1980-06-01"), as.Date("2025-06-01"), by = "5 years"),
    date_labels = "%Y",
    limits = c(as.Date("1979-12-01"), data_end + months(12)),
    expand = expansion(c(0.025, 0.01))
  ) +
  scale_y_continuous(breaks = seq(0, 80, 20)) +
  scale_fill_manual(values = president_colors) +
  guides(fill = "none") +
  labs(
    title = "A história da inflação brasileira",
    subtitle = "Variação mensal do Índice Nacional de Preços ao Consumidor Amplo",
    caption = plot_caption,
    x = NULL,
    y = "IPCA\n(mês, %)"
  ) +
  chart_theme


# Post-Real history ----

post_real_ipca <- ipca |>
  dplyr::mutate(
    accumulated_12m = (RcppRoll::roll_prodr(1 + value / 100, n = 12) - 1) * 100
  ) |>
  dplyr::filter(date >= as.Date("1995-07-01"))

post_real_events <- tidyr::tribble(
  ~date        , ~event                              , ~date_label , ~yseg ,
  "1997-08-01" , "Crise asiática"                    , "1997"      ,    -3 ,
  "1998-08-01" , "Crise russa"                       , "1998"      ,     7 ,
  "1999-01-01" , "Câmbio flutuante"                  , "JAN 1999"  ,    -3 ,
  "1999-08-01" , "Metas de inflação"                 , "JUN 1999"  ,    14 ,
  "2000-07-01" , "Novo regime fiscal"                , "MAI 2000"  ,    -3 ,
  "2002-11-01" , "Argentina + crise de confiança"    , "2002"      ,    -3 ,
  "2008-04-01" , "Brasil obtém grau de investimento" , "SET 2008"  ,    13 ,
  "2008-07-01" , "Crise financeira global"           , "2008"      ,    -3 ,
  "2013-06-01" , "Protestos de 2013"                 , "JUN 2013"  ,    13 ,
  "2014-12-01" , "Reajuste dos preços administrados" , "JAN 2015"  ,    -3 ,
  "2015-09-01" , "Brasil perde grau de investimento" , "SET 2015"  ,    21 ,
  "2016-08-01" , "Impeachment de Dilma"              , "AGO 2016"  ,    -3 ,
  "2016-12-01" , "Teto de gastos"                    , "DEZ 2016"  ,    13 ,
  "2019-10-01" , "Reforma da Previdência"            , "OUT 2019"  ,    -3 ,
  "2020-03-01" , "Covid-19"                          , "MAR 2020"  ,    13 ,
  "2021-03-01" , "Autonomia do Banco Central"        , "FEV 2021"  ,    -3 ,
  "2025-01-01" , "Meta contínua de inflação"         , "JAN 2025"  ,    13
)

right_events <- c(
  "Crise russa",
  "Brasil obtém grau de investimento",
  "Brasil perde grau de investimento",
  "Meta contínua de inflação"
)

post_real_events <- post_real_events |>
  dplyr::mutate(
    date = as.Date(date),
    event_label = stringr::str_wrap(event, width = 13),
    label_shift = dplyr::if_else(
      event == "Meta contínua de inflação",
      months(18),
      months(12)
    ),
    x_event_label = dplyr::if_else(
      event %in% right_events,
      date - label_shift,
      date
    ),
    y_date_label = dplyr::if_else(yseg > 0, yseg - 1.5, -1.5),
    line_count = stringr::str_count(event_label, "\\n"),
    text_offset = 0.75 + 0.5 * line_count,
    ytext = dplyr::if_else(yseg < 0, yseg - text_offset, yseg + text_offset),
    segment_end = dplyr::if_else(
      event %in% right_events,
      date - label_shift,
      date + months(12)
    )
  )

post_real_events <- dplyr::left_join(
  post_real_events,
  post_real_ipca,
  by = "date"
)

plot_inflation_post_real <- ggplot() +
  geom_hline(yintercept = 0, color = ekio_site$ink) +
  geom_rect(
    data = dplyr::filter(presidents, start >= as.Date("1994-01-01")),
    aes(xmin = start, xmax = end, ymin = 0, ymax = 30, fill = name),
    alpha = 0.55
  ) +
  geom_area(
    data = post_real_ipca,
    aes(x = date, y = accumulated_12m),
    fill = ekio_site$ink_600
  ) +
  geom_segment(
    data = post_real_events,
    aes(x = date, xend = date, y = yseg, yend = accumulated_12m),
    color = ekio_site$red
  ) +
  geom_segment(
    data = post_real_events,
    aes(x = date, xend = segment_end, y = yseg, yend = yseg),
    color = ekio_site$red
  ) +
  geom_point(
    data = post_real_events,
    aes(x = date, y = accumulated_12m),
    shape = 21,
    fill = ekio_site$red,
    color = ekio_surface$paper
  ) +
  geom_label(
    data = post_real_events,
    aes(x = date, y = y_date_label, label = date_label),
    family = "Host Grotesk",
    label.r = grid::unit(0, "pt"),
    label.padding = grid::unit(0.1, "line"),
    size = 3,
    fill = ekio_site$ink,
    color = ekio_surface$paper
  ) +
  geom_text(
    data = post_real_events,
    aes(x = x_event_label, y = ytext, label = event_label),
    family = "Host Grotesk",
    size = 3,
    hjust = 0,
    lineheight = 0.8,
    color = ekio_site$ink_700
  ) +
  geom_text(
    data = dplyr::filter(
      presidents,
      x_label >= as.Date("1994-07-01")
    ),
    aes(x = x_label, y = 20.5, label = name),
    angle = 90,
    hjust = 0,
    family = "Host Grotesk",
    color = ekio_site$ink_700
  ) +
  scale_x_date(
    breaks = seq(as.Date("1995-06-01"), as.Date("2025-06-01"), by = "5 years"),
    date_labels = "%Y",
    limits = c(as.Date("1994-07-01"), data_end),
    expand = expansion(mult = c(0, 0.01))
  ) +
  scale_y_continuous(breaks = seq(0, 25, 5)) +
  scale_fill_manual(values = president_colors) +
  guides(fill = "none") +
  labs(
    title = "A inflação depois do Plano Real",
    subtitle = "Variação do IPCA acumulada em 12 meses desde o fim da hiperinflação",
    caption = plot_caption,
    x = NULL,
    y = "IPCA\n(12 meses, %)"
  ) +
  chart_theme


# Export ----

ggsave(
  here::here("insights/posts/2026-01-inflacao-brasil/inflation_historic.png"),
  plot_inflation,
  device = ragg::agg_png,
  width = 16,
  height = 7.5,
  dpi = 300,
  bg = ekio_surface$paper
)

ggsave(
  here::here(
    "insights/posts/2026-01-inflacao-brasil/inflation_historic_post_real.png"
  ),
  plot_inflation_post_real,
  device = ragg::agg_png,
  width = 16,
  height = 7.5,
  dpi = 300,
  bg = ekio_surface$paper
)
