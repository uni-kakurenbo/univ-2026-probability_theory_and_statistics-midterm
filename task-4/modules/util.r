library(dplyr)

extract <- function(pattern, list) {
  base::grep(pattern, unique(list), value = TRUE)[1]
}

to_numeric <<- function(data) {
  data |>
    tidyr::pivot_wider(names_from = "category", values_from = "value") |>
    dplyr::select(-!!dplyr::sym("area")) |>
    dplyr::select(dplyr::where(~ sum(!is.na(.)) >= 30)) |>
    dplyr::select(dplyr::where(~ var(., na.rm = TRUE) > 0))
}

diff <- function(from, to) {
  dplyr::inner_join(
    from, to,
    by = c("area", "category"), suffix = c("_from", "_to")
  ) |>
    dplyr::mutate(
      value_diff = !!dplyr::sym("value_to") - !!dplyr::sym("value_from")
    ) |>
    dplyr::select(
      !!dplyr::sym("area"), !!dplyr::sym("category"),
      value = !!dplyr::sym("value_diff")
    )
}
