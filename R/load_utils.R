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

#' Check whether Python is capable of executing example code
#'
#' Checks if each Python dependency is available.
#' This function is called within some examples to ensure code executes properly.
#' @keywords setup
#' @return `NULL`
python_configured <- function() {

  py_dep <- c("matplotlib","numpy","pandas","tensorflow","sklearn","os","random", "tensorflow_addons")
  dep_avail <- sapply(py_dep, function (x) reticulate::py_module_available(x))

  if (sum(dep_avail) == length(py_dep)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}


