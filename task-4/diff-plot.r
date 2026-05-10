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

data <- diff(data_2013, data_2023)

keywords_x <- c("A05201", "#H01204", "D310305_", "#A06601", "A9112")
# keywords_x <- ("A05201")
keyword_y <- "合計特殊出生率"

cats_x <- unlist(lapply(keywords_x, function(k) extract(k, data$category)))
cats_x <- cats_x[!is.na(cats_x)]

data |>
  plot(cats_x, extract(keyword_y, data$category), normalize = TRUE)
