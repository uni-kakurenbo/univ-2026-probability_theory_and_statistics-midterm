data <-
  read.csv(
    "./data/DI4area.csv",
    header = TRUE,
    check.names = FALSE
  )[, -c(1, 2)]

mean <- colMeans(data, na.rm = TRUE)

lowest <- names(which.min(mean))
highest <- names(which.max(mean))

data_lowest <- data[[lowest]]
data_highest <- data[[highest]]

boxplot(
  data_lowest, data_highest,
  names = c(paste("Lowest:", lowest), paste("Highest:", highest)),
  main = "地域別月次 DI",
  col = c("lightblue", "lightpink"),
  ylab = "Diffusion Index",
  xlab = "Region"
)

t.test(data_lowest, data_highest, paired = TRUE, alternative = "less") |>
  print()
