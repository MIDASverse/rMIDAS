#' Estimate and combine regression models from multiply-imputed data
#'
#' `combine()` calculates *m* individual regression models, then applies "Rubin's Rules" to produce a single, combined estimate of the regression parameters and uncertainty.
#' @keywords import
#' @param formula A formula, or character string coercible to a formula
#' @param df_list A list, containing data.frames or objects coercible to data.frames
#' @param dof_adjust Boolean, indicating whether or not to apply the Rubin and Barnard (1999) degrees of freedom adjustment for small-samples
#' @param ... Further arguments passed onto `glm()`
#' @export
#' @return Data.frame of combined model results.
#' @examples
#' set.seed(89)
#' test_dfs <- lapply(1:5, function (x) data.frame(a = rnorm(1000),
#'                                                 b = runif(1000),
#'                                                 c = 2*rnorm(1000)))
#'
#' midas_res <- combine("a ~ b + c", df_list = test_dfs)
combine <- function(formula, df_list, dof_adjust = TRUE, ...) {

  args <- list(...)
  if (is.null(args[['family']])) {
    message("No model family specified -- assuming gaussian model.\n\n")
  }

  models <- lapply(df_list,
                   function (x) {

                     stats::glm(formula, data = x, ...)

                   })

  mods_est <- sapply(models,
                         function (x) summary(x)$coefficients[,1],
                         simplify = "cbind")

  mods_var <- sapply(models,
                     function (x) diag(stats::vcov(x)),
                     simplify = "cbind")

  m <- length(models)

  Q_bar <- (1/m)*rowSums(mods_est)
  U_bar <- (1/m)*rowSums(mods_var)

  models_demean <- apply(mods_est, 2, function(x) (x-Q_bar)^2)

  B <- (1/(m-1)) * rowSums(models_demean)

  Q_bar_var <- U_bar + (1 + (1/m))*B
  Q_bar_se <- sqrt(Q_bar_var)

  v_m <- (m-1)*(1+(U_bar/((1+m^-1)*B)))^2

  if (dof_adjust) {

    v_complete <- models[[1]]$df.residual

    gamma <- ((1+m^-1)*B)/Q_bar_var

    v_obs <- ((v_complete + 1)/(v_complete+3))*v_complete*(1-gamma)

    v_corrected <- ((1/v_m) + (1/v_obs))^-1

    dof <- v_corrected

  } else {

    dof <- v_m
  }

  est = Q_bar
  std.err = Q_bar_se
  stat = est/std.err

  combined_mat <- data.frame(term = names(est),
                             estimate = est,
                             std.error = std.err,
                             statistic =stat,
                             df = dof,
                             p.value = 2 * stats::pt(abs(stat), dof, lower.tail = FALSE))

  rownames(combined_mat) <- NULL

  return(combined_mat)

}


