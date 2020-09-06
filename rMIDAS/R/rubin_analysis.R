combine <- function(formula, df_list, dof_adjust = TRUE, ...) {

  args <- list(...)
  if (is.null(args[['family']])) {
    cat("No model family specified -- assuming gaussian model.\n\n")
    family <- gaussian
  }

  models <- lapply(df_list,
                   function (x) {

                     glm(formula, data = x, family = family)

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


