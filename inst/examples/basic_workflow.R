# Generate raw data, with numeric, binary, and categorical variables
\donttest{
# Run where Python available
if (reticulate::py_module_available("numpy")) {
set.seed(89)
n_obs <- 10000
raw_data <- data.table(a = sample(c("red","yellow","blue",NA),n_obs, replace = TRUE),
                       b = 1:n_obs,
                       c = sample(c("YES","NO",NA),n_obs,replace=TRUE),
                       d = runif(n_obs,1,10),
                       e = sample(c("YES","NO"), n_obs, replace = TRUE),
                       f = sample(c("male","female","trans","other",NA), n_obs, replace = TRUE))

# Names of bin./cat. variables
test_bin <- c("c","e")
test_cat <- c("a","f")

# Pre-process data
test_data <- convert(raw_data,
                     bin_cols = test_bin,
                     cat_cols = test_cat,
                     minmax_scale = TRUE)

# Run imputations
test_imp <- train(test_data)

# Generate datasets
complete_datasets <- complete(test_imp, m = 5, fast = FALSE)

# Use Rubin's rules to combine m regression models
midas_pool <- combine(formula = d~a+c+e+f,
                      complete_datasets)
}
}

