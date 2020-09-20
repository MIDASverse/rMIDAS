context("Test pre-processing functions")
library(rMIDAS)

test_that("convert function works", {

  skip_if_no_numpy()

  test_data <- data.frame(a = sample(c("red","yellow","blue",NA),1000, replace = TRUE),
                          b = seq(0.265,1000),
                          c = sample(c("YES","NO",NA),1000,replace=TRUE),
                          stringsAsFactors = FALSE)

  converted_data <- convert(test_data,
                           bin_cols = "c",
                           cat_cols = "a",
                           minmax_scale = TRUE)

  expect_equal(length(converted_data), 5)
  expect_equal(ncol(converted_data$data), 5)
  expect_equal("a_red" %in% colnames(converted_data$data), TRUE)
  expect_equal(range(converted_data$data[["b"]]), c(0,1))
  expect_equal(typeof(converted_data$data[["c"]]), "integer")

})
