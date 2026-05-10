source("./task-4/modules/util.r")
source("./task-4/modules/display.r")
source("./task-4/modules/load.r")
source("./task-4/modules/ratio.r")

data <-
  set_source("./data/merged-2023.csv", "2023") |>
  with_fallback("./data/merged-2022.csv", "2022") |>
  with_fallback("./data/merged-2021.csv", "2021") |>
  load()

data |>
  calc_ratio_corrs(extract("合計特殊出生率", data$category)) |>
  display()
