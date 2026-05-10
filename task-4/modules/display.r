dump <- function(sorted) {
  for (cat_name in names(sorted)) {
    cat(sprintf("相関係数: %6.3f; カテゴリ: %s\n", sorted[cat_name], cat_name))
  }
}

display <- function(corrs, n = 50) {
  cat("Strongest:\n")
  sorted_by_abs <- head(corrs[order(abs(corrs), decreasing = TRUE)], n)
  dump(sorted_by_abs)

  cat("\nStrongest (Positive):\n")
  top_pos <- head(sort(corrs, decreasing = TRUE), n)
  dump(top_pos)

  cat("\nStrongest (Negative):\n")
  top_neg <- head(sort(corrs, decreasing = FALSE), n)
  dump(top_neg)
}
