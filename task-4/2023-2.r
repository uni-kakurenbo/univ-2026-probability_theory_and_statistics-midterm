source("./task-4/modules/util.r")
source("./task-4/modules/load.r")
source("./task-4/modules/corr.r")
source("./task-4/modules/display.r")

data <-
  set_source("./data/merged-2023.csv", "2023") |>
  with_fallback("./data/merged-2022.csv", "2022") |>
  with_fallback("./data/merged-2021.csv", "2021") |>
  load() |>
  dplyr::select(-unit) |>
  dplyr::filter(!grepl("小学校|中学校", !!dplyr::sym("category")))

target <- extract("合計特殊出生率", data$category)
denom_cat <- extract("A110102_", data$category)

numeric <- data |> to_numeric()

data_ratio <- numeric |>
  dplyr::mutate(dplyr::across(
    -dplyr::all_of(c(target, denom_cat)),
    ~ . / !!dplyr::sym(denom_cat)
  ))

data_ratio |>
  calc_corrs(target) |>
  display(n = 15)
