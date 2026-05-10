domain <- read.csv("./data/DI4domain.csv", header = TRUE)
area <- read.csv("./data/DI4area.csv", header = TRUE)

corrs <- setdiff(names(area), c("Month", "Japan")) |>
  sapply(function(reg) {
    cor(domain$Kakei, area[[reg]])
  })

lowest <- names(which.min(corrs))

sprintf("Lowest Region: %s (Corr: %.4f)\n", lowest, corrs[lowest]) |>
  cat()

x <- area[[lowest]]
y <- domain$Kakei

plot(
  x,
  y,
  xlab = paste(lowest, " DI"),
  ylab = "家計動向関連 DI",
  col = "lightblue",
  pch = 16
)

model <- lm(y ~ x)
abline(model, col = "lightpink", lwd = 2)

sprintf("Kakei = %.4f × %s + %.4f\n", coef(model)[2], lowest, coef(model)[1]) |>
  cat()
