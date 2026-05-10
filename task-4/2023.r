library(dplyr)

source("./task-4/modules/util.r")
source("./task-4/modules/load.r")
source("./task-4/modules/corr.r")
source("./task-4/modules/display.r")

data <-
  set_source("./data/merged-2023.csv", "2023") |>
  with_fallback("./data/merged-2022.csv", "2022") |>
  with_fallback("./data/merged-2021.csv", "2021") |>
  load() |>
  dplyr::select(-unit)

data |>
  to_numeric() |>
  calc_corrs(extract("合計特殊出生率", data$category)) |>
  display(n = 200)
