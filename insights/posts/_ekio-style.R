# Shared figure and table styling for the Insights posts.
# Sourced from a post with: source("../_ekio-style.R")
# The leading underscore keeps Quarto from treating this as an input file.

library(ggplot2)
library(ekioplot)
library(ekiotable)

# Pigments ----
# Read off the Hokusai plates in static/images/art/reference. Section 1 of
# the color block in static/css/custom.scss, which this file mirrors token
# for token so a figure sits on the same paper as the page around it.
ekio_pigment <- list(
  alabaster = "#D4DED9",
  soft_linen = "#EFE8DC",
  soft_linen_2 = "#F2EDE2",
  baltic_blue = "#225A7E",
  air_force_blue = "#517A90"
)

# Hokusai paper ramp ----
# Sampled from two plates in static/images/art/reference: Inume Pass
# (79485-1-primary.webp) and Lake Suwa (DP141058.jpg). Both scans are aged
# paper under gallery light, so their measured paper is far darker than a
# screen background. The two agree on hue (h ~95, warm), so one ramp serves
# both: hold the hue, scale chroma with the headroom left to white.
#
# $ink-400 (#6E7378) is the lightest neutral the site sets small text in and
# needs 4.5:1. The ramp crosses that line between L*97 and L*96, so the
# darker rungs belong to bands and panels, not to the page.
ekio_paper <- list(
  # L*98.5; ink-400 4.63
  linen_98 = "#FCFBF8",
  # L*97.5; ink-400 4.50 — the floor for body text
  linen_97 = "#F9F8F3",
  # L*97.5 read off Inume alone; warmer, ink-400 4.51
  linen_97_warm = "#FAF8F3",
  # L*96.5; ink-400 4.40 — bands only
  linen_96 = "#F7F5EE",
  # L*95.5; ink-400 4.28 — bands only
  linen_95 = "#F5F2E9",
  # L*94.5; ink-400 4.17 — bands only
  linen_94 = "#F3EFE4",
  # Pre-Hokusai page color, warmer than the ramp; ink-400 4.55
  old_1 = "#FAF9F7",
  # Soft Linen 2, the long-standing recessed band; ink-400 4.10
  old_2 = "#F2EDE2"
)

# Paper as measured, before lifting to screen lightness. Reference only.
ekio_paper_measured <- list(
  inume = "#F3EEE2", # L*94.2, C 6.3
  suwa = "#DDD5BA" # L*85.3, C 14.6
)

# Surface switch ----
# The page and the band recessed under it, both drawn from the ramp above.
# Change these two lines to reswatch the figures; mirror them in
# static/css/custom.scss, which carries the same switch for the pages.
ekio_surface <- list(
  paper = ekio_paper$linen_97_warm,
  sunk = ekio_paper$linen_94
)

# Site tokens ----
# Every color the stylesheet paints with, in its section order. The page
# owns the surfaces; ekioplot owns the data colors.
ekio_site <- list(
  # ── Derived surfaces ──
  # $paper
  paper = ekio_surface$paper,
  # $paper-sunk
  paper_sunk = ekio_surface$sunk,
  # $canvas; outside the frame
  canvas = ekio_pigment$soft_linen,
  # $rule; hairline
  rule = ekio_pigment$alabaster,
  # $rule-strong; ekioplot stone.300
  rule_strong = "#B4B0AB",

  # ── Ink ──
  # $ink; ekioplot gray.900
  ink = "#191A1C",
  # $ink-700; ekioplot gray.800
  ink_700 = "#28292C",
  # $ink-600; ekioplot gray.700, the body color
  ink_600 = "#373A3D",
  # $ink-500; ekioplot gray.600
  ink_500 = "#52555A",
  # $ink-400; ekioplot gray.500, AA on $paper
  ink_400 = "#6E7378",
  # $ink-300; lightest accessible small-text neutral
  ink_300 = "#6E7378",
  # $ink-inverse-muted; ekioplot gray.300 on dark surfaces
  ink_inverse_muted = "#AEB1B5",

  # ── Accent ──
  # $navy — equals ekio_pal("full")[1]
  navy = "#1E3A5F",
  # $navy-deep; ekioplot blue.800
  navy_deep = "#152A44",
  # $navy-tint; ekioplot blue.100
  navy_tint = "#E8F6FF",

  # ── Data colors ──
  # $ekio-orange; ekioplot orange.400
  orange = "#D3742A",
  # $ekio-teal; ekioplot teal.600
  teal = "#006261",
  # $ekio-amber; ekioplot gold.mid
  amber = "#B88715",
  # $ekio-red; ekioplot red.500
  red = "#B44D47",
  # $ekio-green; ekioplot green.500
  green = "#448255"
)

# Chart theme ----
# theme_ekio() with the page's paper as canvas color, so a figure sits on
# the page without a seam.
theme_ekio_site <- function(...) {
  theme_ekio(...) +
    theme_sub_plot(
      background = element_rect(fill = ekio_site$paper, color = NA),
      title = element_text(size = 18),
      subtitle = element_text(size = 12),
      caption = element_text(size = 10)
    ) +
    theme_sub_panel(
      background = element_rect(fill = ekio_site$paper, color = NA)
    )
}

# Reference lines ----
# geom_hline()/geom_vline() default to black, which outweighs the series.
# ekio_rule_color <- ekio_pal("gray")[["500"]]

# Table theme ----

# DEPRECATED: use ekiotable::gt_theme_hokusai() instead
# Rules carry structure, nothing is filled; column labels borrow
# .section-label/.credential-label microtypography. Letter-spacing and
# tabular figures come from custom.scss, not tab_options().
# gt_theme_ekio <- function(data, accent = ekio_site$ink) {
#   data |>
#     gt::tab_options(
#       # Width is left to the stylesheet; a wide table scrolls rather than
#       # crushing columns to fit.
#       table.align = "left",
#       table.font.size = gt::px(14),
#       table.font.weight = "400",
#       table.font.color = ekio_site$ink_600,
#       table.background.color = ekio_site$paper,

#       # A rule opens and closes the table; the interior stays open.
#       table.border.top.style = "solid",
#       table.border.top.width = gt::px(1),
#       table.border.top.color = accent,
#       table.border.bottom.style = "solid",
#       table.border.bottom.width = gt::px(1),
#       table.border.bottom.color = accent,

#       column_labels.background.color = ekio_site$paper,
#       column_labels.font.size = gt::px(11),
#       column_labels.font.weight = "400",
#       column_labels.text_transform = "uppercase",
#       column_labels.padding = gt::px(10),
#       column_labels.border.top.style = "none",
#       column_labels.border.bottom.style = "solid",
#       column_labels.border.bottom.width = gt::px(1),
#       column_labels.border.bottom.color = ekio_site$rule_strong,

#       data_row.padding = gt::px(9),
#       # No interior hairlines; they'd collapse into the header rule and
#       # blur it into a plain row divider.
#       table_body.border.top.style = "none",
#       table_body.border.bottom.style = "none",
#       table_body.hlines.style = "none",

#       source_notes.font.size = gt::px(11),
#       source_notes.background.color = ekio_site$paper,
#       footnotes.font.size = gt::px(11),
#       footnotes.background.color = ekio_site$paper,
#       heading.background.color = ekio_site$paper,
#       heading.align = "left"
#     ) |>
#     gt::tab_style(
#       style = gt::cell_text(color = ekio_site$ink_300),
#       locations = gt::cells_column_labels()
#     )
# }
