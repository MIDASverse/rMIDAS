#' Another test function
#'
#' This function cannot be used until i work out how testhat works
#' @param
#' @keywords test
#' @export
#' @examples
#' skip_if_no_scipy()

skip_if_no_scipy <- function() {
  have_scipy <- py_module_available("scipy")
  if (!have_scipy)
    skip("scipy not available for testing")
}

# then call this function from all of your tests
# test_that("Things work as expected", {
#   skip_if_no_scipy()
#   # test code here...
# })
