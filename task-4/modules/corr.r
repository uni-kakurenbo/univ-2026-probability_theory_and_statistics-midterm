library(dplyr)

calc_corrs <- function(data, target) {
  corrs <- cor(
    data[[target]],
    data,
    use = "pairwise.complete.obs"
  )

  corrs <- as.vector(corrs)
  names(corrs) <- colnames(data)
  corrs <- corrs[names(corrs) != target]
}
