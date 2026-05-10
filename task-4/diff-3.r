library(dplyr)

source("./task-4/modules/load.r")
source("./task-4/modules/corr.r")
source("./task-4/modules/display.r")
source("./task-4/modules/util.r")

data_2013 <- set_source("./data/merged-2013.csv") |>
  with_fallback("./data/merged-2012.csv") |>
  with_fallback("./data/merged-2011.csv") |>
  load() |>
  dplyr::select(-unit)

data_2023 <- set_source("./data/merged-2023.csv") |>
  with_fallback("./data/merged-2022.csv") |>
  with_fallback("./data/merged-2021.csv") |>
  load() |>
  dplyr::select(-unit)

numeric_2023 <- data_2023 |> to_numeric()
numeric_2013 <- data_2013 |> to_numeric()

target <- extract("合計特殊出生率", data_2023$category)

numeric <- numeric_2023
numeric[[target]] <- numeric_2023[[target]] - numeric_2013[[target]]

target <- extract("合計特殊出生率", data_2023$category)
denom_cat <- extract("A110102_", data_2023$category)

data_ratio <- numeric |>
  dplyr::mutate(dplyr::across(
    -dplyr::all_of(c(target, denom_cat)),
    ~ . / !!dplyr::sym(denom_cat)
  ))

data_ratio |>
  calc_corrs(target) |>
  display(n = 15)
