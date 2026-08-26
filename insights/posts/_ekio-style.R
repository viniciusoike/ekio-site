# Shared figure and table styling for the Insights posts.
# Sourced from a post with: source("../_ekio-style.R")
# The leading underscore keeps Quarto from treating this as an input file.

library(ggplot2)
library(ekioplot)

# Site surface tokens ----
#
# Mirrors the SCSS variables in static/css/custom.scss. Charts and tables sit
# on the page, so the page owns the surface; ekioplot owns the data colors.
# Edit both files together.
ekio_site <- list(
  paper = "#FEFEFE", # $paper; ekioplot basic.offwhite
  paper_sunk = "#F2EDE2", # $paper-sunk; Hokusai Soft Linen 2
  rule = "#D4DED9", # $rule; Hokusai Alabaster Grey
  rule_strong = "#B4B0AB", # $rule-strong; ekioplot stone.300
  ink = "#191A1C", # $ink; ekioplot gray.900
  ink_700 = "#28292C", # $ink-700; ekioplot gray.800
  ink_600 = "#373A3D", # $ink-600; ekioplot gray.700
  ink_400 = "#6E7378", # $ink-400; ekioplot gray.500
  ink_300 = "#6E7378", # $ink-300; lightest accessible neutral
  navy = "#1E3A5F", # $navy — equals ekio_pal("full")[1]
  teal = "#006261" # $ekio-teal; ekioplot teal.600
)

# Chart theme ----
#
# theme_ekio() with the page's paper as the canvas. The `background` argument
# only takes named tokens ("offwhite", "white", "gray", "transparent"), and its
# named off-white is the same #FEFEFE used by $paper.
theme_ekio_site <- function(...) {
  theme_ekio(...) +
    theme(
      plot.background = element_rect(fill = ekio_site$paper, color = NA),
      panel.background = element_rect(fill = ekio_site$paper, color = NA)
    )
}

# Reference lines ----
#
# geom_hline()/geom_vline() default to black, which outweighs the series.
ekio_rule_color <- ekio_pal("gray")[["500"]]

# Table theme ----
#
# The stylesheet's own brief is "hairline rules instead of cards", so a table
# is set the way the rest of the site is: rules carry the structure, nothing is
# filled, and the column labels borrow the microtypography of .section-label
# and .credential-label. Letter-spacing and tabular figures are not expressible
# through tab_options() and come from custom.scss.
gt_theme_ekio <- function(data, accent = ekio_site$ink) {
  data |>
    gt::tab_options(
      # Width is left to the stylesheet, which floors it at the column and
      # lets a genuinely wide table overflow into a scroll instead of
      # crushing nine columns into the measure.
      table.align = "left",
      table.font.size = gt::px(14),
      table.font.weight = "400",
      table.font.color = ekio_site$ink_600,
      table.background.color = ekio_site$paper,

      # A rule opens and closes the table; the interior stays open.
      table.border.top.style = "solid",
      table.border.top.width = gt::px(1),
      table.border.top.color = accent,
      table.border.bottom.style = "solid",
      table.border.bottom.width = gt::px(1),
      table.border.bottom.color = accent,

      column_labels.background.color = ekio_site$paper,
      column_labels.font.size = gt::px(11),
      column_labels.font.weight = "400",
      column_labels.text_transform = "uppercase",
      column_labels.padding = gt::px(10),
      column_labels.border.top.style = "none",
      column_labels.border.bottom.style = "solid",
      column_labels.border.bottom.width = gt::px(1),
      column_labels.border.bottom.color = ekio_site$rule_strong,

      data_row.padding = gt::px(9),
      # No interior hairlines. They collapse against the rule under the column
      # labels, which then reads no heavier than an ordinary row divider and
      # leaves the head without separation.
      table_body.border.top.style = "none",
      table_body.border.bottom.style = "none",
      table_body.hlines.style = "none",

      source_notes.font.size = gt::px(11),
      source_notes.background.color = ekio_site$paper,
      footnotes.font.size = gt::px(11),
      footnotes.background.color = ekio_site$paper,
      heading.background.color = ekio_site$paper,
      heading.align = "left"
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = ekio_site$ink_300),
      locations = gt::cells_column_labels()
    )
}
