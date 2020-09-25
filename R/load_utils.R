#' Skip test where 'numpy' not available.
#'
#' Check if Python's numpy is available, and skip test if not.
#' This function is called within some tests to ensure server tests involving `reticulate` calls execute properly.
#' @keywords setup
#' @return `NULL`
skip_if_no_numpy <- function() {
  have_numpy <- reticulate::py_module_available("numpy")
  if (!have_numpy)
    testthat::skip("numpy not available for testing")
}
