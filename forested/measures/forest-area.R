#' Percent of Washington that is forested
#'
#' The official estimate of the share of Washington's land area that is
#' forested, using FIA's post-stratified estimator (Bechtold and Patterson
#' 2005, equations 4.3-4.6). Plots are post-stratified by the LANDFIRE
#' tree/non-tree lifeform mask, and each stratum's share of forested plots is
#' weighted by that stratum's share of the state's land area. All inventory
#' years are pooled, following the temporally indifferent method (section
#' 5.2.2). Use this for questions about how much of Washington is forested.
#'
#' @return A table with the estimated percent forested, its standard error, a
#'   95% confidence interval, and the number of plots.
#' @measure
pct_forested_post_stratified <- function(fia) {
  plots <- DBI::dbGetQuery(fia, "SELECT forested, tree_no_tree FROM plots")
  strata <- DBI::dbGetQuery(fia, "SELECT stratum, weight FROM strata")

  result <- post_stratified_estimate(
    y = as.character(plots$forested) == "Yes",
    stratum = as.character(plots$tree_no_tree),
    weights = stats::setNames(strata$weight, as.character(strata$stratum))
  )

  data.frame(
    estimate = 100 * result$estimate,
    se = 100 * result$se,
    lower = 100 * (result$estimate - 1.96 * result$se),
    upper = 100 * (result$estimate + 1.96 * result$se),
    plots = result$n
  ) |>
    gt::gt() |>
    gt::tab_header(title = "Percent of Washington that is forested") |>
    gt::fmt_number(columns = c(estimate, se, lower, upper), decimals = 1) |>
    gt::fmt_integer(columns = plots) |>
    gt::cols_merge_range(col_begin = lower, col_end = upper, sep = " to ") |>
    gt::cols_label(
      estimate = "Estimate (%)",
      se = "Std. error",
      lower = "95% CI",
      plots = "Plots"
    ) |>
    gt::tab_source_note(
      "Post-stratified by the LANDFIRE tree/non-tree mask (Bechtold and Patterson 2005)."
    )
}

post_stratified_estimate <- function(y, stratum, weights) {
  n <- length(y)
  n_h <- tapply(y, stratum, length)
  mean_h <- tapply(y, stratum, mean)
  var_mean_h <- tapply(y, stratum, stats::var) / n_h
  w_h <- weights[names(n_h)]

  # Equation 4.6, divided by A_T^2 to give the variance of the proportion
  variance <- (
    sum(w_h * n_h * var_mean_h) + sum((1 - w_h) * n_h / n * var_mean_h)
  ) / n

  list(estimate = sum(w_h * mean_h), se = sqrt(variance), n = n)
}
