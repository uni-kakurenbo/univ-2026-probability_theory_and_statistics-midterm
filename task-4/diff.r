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

diff(data_2013, data_2023) |>
  to_numeric() |>
  calc_corrs(extract("合計特殊出生率", data$category)) |>
  display(n = 200)
