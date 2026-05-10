library(dplyr)
library(tidyr)
library(ppcor)

source("./task-4/modules/util.r")
source("./task-4/modules/load.r")

data <-
  set_source("./data/merged-2023.csv", "2023") |>
  with_fallback("./data/merged-2022.csv", "2022") |>
  with_fallback("./data/merged-2021.csv", "2021") |>
  load() |>
  dplyr::select(-unit)

keyword_x <- "合計特殊出生率"
keyword_y <- "A9111"
keyword_z <- "A9112"

x <- extract(keyword_x, data$category)
y <- extract(keyword_y, data$category)
z <- extract(keyword_z, data$category)

numeric <- data |>
  to_numeric()

cor(numeric[[x]], numeric[[y]], use = "pairwise.complete.obs") |>
  print()
ppcor::pcor.test(numeric[[x]], numeric[[y]], numeric[[z]]) |>
  print()
