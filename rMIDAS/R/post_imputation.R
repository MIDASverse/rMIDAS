# Run imputation models  -- essentially a wrapper for mice or whatever we use in the

#' Reverse minmax scaling of numeric vector
#'
#' Helper function to reverse minmax scaling applied in the pre-processing step.
#' @keywords postprocessing
#' @param s a numeric vector or column, scaled between 0 and 1.
#' @param s_min a numeric value, the minimum of the unscaled variable
#' @param s_max a numeric value, the maximum of the unscaled variable
#' @export
#' @examples
#' ex_num <- runif(100,1,10)
#' scaled <- col_minmax(ex_num)
#' undo_scale <- undo_minmax(scaled, s_min = min(ex_num), s_max = max(ex_num))
#'
#' # Prove two are identical
#' all.equal(ex_num, undo_scale)
undo_minmax <- function(s, s_min, s_max) {

  x <- s*(s_max-s_min) + s_min

}

#' Reverse minmax scaling of numeric vector
#'
#' Helper function to re-apply binary variable labels post-imputation.
#' @keywords postprocessing
#' @param x a numeric vector or column, scaled between 0 and 1.
#' @param one a character string, the label associated with binary value 1
#' @param zero a character string, the label associated with binary value 0
#' @export
#' @examples
#' ex_bin <- --c(1,0,0,1,1,0,0,1,0)
#' cat <- "cat"
#' dog <- "dog"
#'
#' add_bin_labels(x = ex_bin, one = cat, zero = dog)
add_bin_labels <- function(x, one, zero) {

  x_out <- factor(ifelse(x == 1, one,ifelse(x==0,zero,NA)), levels = c(zero, one))

  return(x_out)

}

#' Coalesce one-hot encoding back to a single variable
#'
#' Helper function to reverse one-hot encoding post-imputation.
#' @keywords postprocessing
#' @param X a data.frame, data.table or matrix, for a single variable.
#' @param cat_names a character vector, containing one-hot column names
#' @export
#' @examples
#' ex_bin <- --c(1,0,0,1,1,0,0,1,0)
#' cat <- "cat"
#' dog <- "dog"
#'
#' add_bin_labels(x = ex_bin, one = cat, zero = dog)
coalesce_one_hot <- function(X, var_name) {

  X_copy <- data.table::copy(X)

  X_max <- apply(X_copy, 1, which.max)

  X_max_cat <- sub(paste0(var_name,"_"),"",names(X_copy))[X_max]

  return(X_max_cat)

}

