library(dplyr)
library(ggplot2)
library(tidyr)

plot <- function(data, cats_x, cat_y, normalize = TRUE) {
  plot_data <-
    data |>
    dplyr::filter(!!dplyr::sym("category") %in% c(cats_x, cat_y)) |>
    tidyr::pivot_wider(
      names_from = !!dplyr::sym("category"),
      values_from = !!dplyr::sym("value")
    ) |>
    dplyr::filter(!is.na(!!dplyr::sym(cat_y)))

  valid_cats_x <- intersect(cats_x, colnames(plot_data))

  cor_labels <- sapply(valid_cats_x, function(cx) {
    cor_val <- cor(plot_data[[cx]], plot_data[[cat_y]], use = "complete.obs")
    sprintf("%s (r=%.3f)", cx, cor_val)
  })

  if (normalize) {
    plot_data <- plot_data |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(valid_cats_x),
        ~ as.numeric(scale(.))
      ))
  }

  plot_longer <- plot_data |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(valid_cats_x),
      names_to = "x_category",
      values_to = "x_value"
    ) |>
    dplyr::filter(!is.na(!!dplyr::sym("x_value"))) |>
    dplyr::mutate(
      cor_label = cor_labels[match(!!dplyr::sym("x_category"), valid_cats_x)]
    )

  title <- paste("Scatter Plot", if (normalize) "(Normalized)" else "")

  p <-
    plot_longer |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = !!dplyr::sym("x_value"), y = !!dplyr::sym(cat_y),
        color = !!dplyr::sym("cor_label"),
        fill = !!dplyr::sym("cor_label"),
        label = !!dplyr::sym("cor_label")
      )
    ) +
    ggplot2::geom_point(size = 2, alpha = 0.8) +
    ggplot2::geom_smooth(
      method = "lm", formula = y ~ x,
      alpha = 0.2
    ) +
    ggplot2::theme_minimal(base_family = "Meiryo") +
    ggplot2::labs(
      title = title,
      x = NULL,
      y = cat_y,
      color = "Legend",
      fill = "Legend"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 10),
      axis.title = ggplot2::element_text(size = 10),
      legend.position = "bottom",
      legend.direction = "vertical"
    )

  print(p)
}
