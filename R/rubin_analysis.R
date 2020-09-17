#' Calculate and combine *m* regression models
#'
#' `combine()` calculates *m* individual regression models, then applies "Rubin's Rules" (1987) to produce a single, combined estimate of the regression parameters and uncertainty.
#' @keywords import
#' @param formula a model formula or string coercible to a formula
#' @param df_list a list of completed data.frames or objects coercible to data.frames
#' @param dof_adjust a boolean, indicating whether or not to apply the Rubin and Barnard (1999) degrees of freedom adjustment for small-samples
#' @param ... Further arguments passed onto `glm()`, enabling users to run other model families.
#' @export
#' @return Dataframe of combined model results.
#' @examples
#' # Generate raw data, with numeric, binary, and categorical variables
#' raw_data = data.frame(a = sample(c("red","yellow","blue",NA),1000, replace = TRUE),
#'                       b = 1:1000,
#'                       c = sample(c("YES","NO",NA),1000,replace=TRUE),
#'                       d = runif(1000,1,10),
#'                       e = sample(c("YES","NO"), 1000, replace = TRUE),
#'                       f = sample(c("male","female","trans","other",NA), 1000, replace = TRUE))
#'
#' # Names of bin./cat. variables
#' test_bin <- c("c","e")
#' test_cat <- c("a","f")
#'
#' # Pre-process data
#' test_data <- convert(raw_data,
#'                      bin_cols = test_bin,
#'                      cat_cols = test_cat,
#'                      minmax_scale = TRUE)
#'
#' # Train imputation model
#' test_model <- train(test_data)
#'
#' # Generate datasets
#' complete_datasets <- complete(test_imp, m = 5)
#'
#' combine(formula = d~a+c+e+f, complete_datasets)
combine <- function(formula, df_list, dof_adjust = TRUE, ...) {

  args <- list(...)
  if (is.null(args[['family']])) {
    cat("No model family specified -- assuming gaussian model.\n\n")
    family <- gaussian
  }

  models <- lapply(df_list,
                   function (x) {

                     glm(formula, data = x, family = family, ...)

                   })

  mods_est <- sapply(models,
                         function (x) summary(x)$coefficients[,1],
                         simplify = "cbind")

  mods_var <- sapply(models,
                     function (x) diag(vcov(x)),
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

  combined_mat <- data.frame(estimate = est,
                             std.error = std.err,
                             statistic =stat,
                             p.value = 2 * pt(abs(stat), dof, lower.tail = FALSE))

  return(combined_mat)

}


