context("Rubin's rules")
library(rMIDAS)

test_that("midas combine equals mice pool results", {

  skip_if_no_numpy()

  set.seed(89)
  test_dfs <- lapply(1:5, function (x) data.frame(a = rnorm(1000),
                                                  b = runif(1000),
                                                  c = 2*rnorm(1000)))

  midas_res <- combine("a ~ b + c", df_list = test_dfs)
  # mice_res <- mice::pool(lapply(test_dfs, function(x) glm("a~b+c", data = x)))
  # summary(mice_res)

  expect_equal(round(midas_res$estimate[1],5), 0.00737)
  expect_equal(round(midas_res$std.error[2],5), 0.14832)
  expect_equal(round(midas_res$statistic[3],5), -0.06527)
  expect_equal(round(midas_res$df[1],5), 23.59657)
  expect_equal(round(midas_res$p.value[2],5), 0.92833)

})
