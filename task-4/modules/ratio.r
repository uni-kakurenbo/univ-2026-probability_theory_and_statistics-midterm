library(dplyr)
library(tidyr)

calc_ratio_corrs <- function(data, target) {
  target_data <- data |>
    dplyr::filter(!!dplyr::sym("category") == target)

  count_data <- data |>
    dplyr::filter(!!dplyr::sym("category") != target) |>
    dplyr::filter(!(
      !!dplyr::sym("unit") %in%
        c("%", "‐", "-", "％", "－", "人", "万人")
    )) |>
    dplyr::filter(!grepl("気温|小学校", !!dplyr::sym("category")))

  pivot_count <- count_data |>
    dplyr::select(
      !!dplyr::sym("area"), !!dplyr::sym("category"), !!dplyr::sym("value")
    ) |>
    tidyr::pivot_wider(
      names_from = !!dplyr::sym("category"),
      values_from = !!dplyr::sym("value")
    ) |>
    dplyr::select(dplyr::where(~ sum(!is.na(.)) >= 30))

  pivot_target <- target_data |>
    dplyr::select(
      !!dplyr::sym("area"), !!dplyr::sym("category"), !!dplyr::sym("value")
    ) |>
    tidyr::pivot_wider(
      names_from = !!dplyr::sym("category"),
      values_from = !!dplyr::sym("value")
    )

  joined <- pivot_target |>
    dplyr::inner_join(pivot_count, by = "area")

  numeric_data <- joined |>
    dplyr::select(-!!dplyr::sym("area")) |>
    dplyr::select(dplyr::where(~ min(., na.rm = TRUE) > 0)) |>
    dplyr::select(dplyr::where(~ var(., na.rm = TRUE) > 0))

  y <- numeric_data[[target]]
  x <- numeric_data |> dplyr::select(-dplyr::all_of(target))

  x_mat <- as.matrix(x)
  n_cols <- ncol(x_mat)
  col_names <- colnames(x_mat)

  n_pairs <- n_cols * (n_cols - 1)
  results_num <- character(n_pairs)
  results_den <- character(n_pairs)
  results_cor <- numeric(n_pairs)

  cat("Calculating pairwise ratio correlations...\n")

  idx <- 1
  for (i in seq_len(n_cols)) {
    num_vec <- x_mat[, i]

    den_idx <- setdiff(seq_len(n_cols), i)
    den_mat <- x_mat[, den_idx, drop = FALSE]

    den_mat[den_mat == 0] <- NA

    ratio_mat <- num_vec / den_mat

    cor_vals <- cor(y, ratio_mat, use = "pairwise.complete.obs")

    n_current <- length(den_idx)
    range <- idx:(idx + n_current - 1)

    results_num[range] <- rep(col_names[i], n_current)
    results_den[range] <- col_names[den_idx]
    results_cor[range] <- as.vector(cor_vals)

    idx <- idx + n_current
  }

  res_df <- data.frame(
    ratio_name = paste0(results_num, " / ", results_den),
    cor = results_cor,
    stringsAsFactors = FALSE
  )

  res_df <- res_df |> dplyr::filter(!is.na(cor))

  corrs_vec <- res_df$cor
  names(corrs_vec) <- res_df$ratio_name

  corrs_vec
}
