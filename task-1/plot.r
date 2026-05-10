data <- read.csv("./data/DI4domain.csv", header = TRUE)
koyou <- data$Koyou

hist(
  koyou,
  breaks = seq(min(koyou), max(koyou), length.out = nclass.Sturges(koyou) + 1),
  col = "pink",
  main = "分野別月次 DI (雇用関連)",
  xlab = "Diffusion Index",
  ylab = "Frequency",
)
