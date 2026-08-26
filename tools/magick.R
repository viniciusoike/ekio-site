library(magick)

img <- image_read(here::here("static/images/art/reference/banner.png"))

export_web <- function(
  input,
  output_dir = here::here("static/images/art/finished"),
  sizes = c(800, 1600, 2400, 3200),
  quality = 85
) {
  img <- magick::image_read(input)
  name <- tools::file_path_sans_ext(basename(input))

  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  for (size in sizes) {
    img |>
      magick::image_resize(paste0(size, "x")) |>
      magick::image_write(
        file.path(
          output_dir,
          paste0(name, "-", size, ".webp")
        ),
        format = "webp",
        quality = quality
      )
  }
}

export_web(here::here("static/images/art/reference/banner.png"))
