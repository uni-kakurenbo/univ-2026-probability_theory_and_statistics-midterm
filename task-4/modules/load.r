library(dplyr)
library(readr)

set_source <- function(file_path, tag = NA) {
  data <- readr::read_csv(file_path, show_col_types = FALSE)
  data$value <- as.numeric(data$value)

  data |>
    dplyr::group_by(
      !!dplyr::sym("area"),
      !!dplyr::sym("category"),
      !!dplyr::sym("unit")
    ) |>
    dplyr::summarise(
      value = mean(!!dplyr::sym("value"), na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(tag = as.character(tag))
}

with_fallback <- function(data, source, tag = NA) {
  missing_data <-
    set_source(source, tag) |>
    dplyr::anti_join(
      data,
      by = c("area", "category")
    )
  data |>
    dplyr::bind_rows(missing_data)
}

load <- function(data) {
  data |>
    dplyr::mutate(
      category = paste0(
        !!dplyr::sym("category"),
        ifelse(
          !is.na(!!dplyr::sym("tag")),
          paste0(" [", !!dplyr::sym("tag"), "]"),
          ""
        )
      )
    ) |>
    dplyr::select(
      !!dplyr::sym("area"),
      !!dplyr::sym("category"),
      !!dplyr::sym("unit"),
      !!dplyr::sym("value")
    )
}
