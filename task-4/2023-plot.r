library(dplyr)

source("./task-4/modules/util.r")
source("./task-4/modules/load.r")
source("./task-4/modules/plot.r")

data <-
  set_source("./data/merged-2023.csv", "2023") |>
  with_fallback("./data/merged-2022.csv", "2022") |>
  with_fallback("./data/merged-2021.csv", "2021") |>
  load() |>
  dplyr::select(-unit)

keywords_x <- c("#L04424", "A9111", "L3124", "#M0310202", "M350200")
# keywords_x <- ("#L04424")
keyword_y <- "合計特殊出生率"

cats_x <- unlist(lapply(keywords_x, function(k) extract(k, data$category)))
cats_x <- cats_x[!is.na(cats_x)]

data |>
  plot(cats_x, extract(keyword_y, data$category), normalize = TRUE)
