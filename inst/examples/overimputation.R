\donttest{
# Run where Python available
if (reticulate::py_module_available("numpy")) {

raw_data <- data.table(a = sample(c("red","yellow","blue",NA),1000, replace = TRUE),
                         b = 1:1000,
                         c = sample(c("YES","NO",NA),1000,replace=TRUE),
                         d = runif(1000,1,10),
                         e = sample(c("YES","NO"), 1000, replace = TRUE),
                         f = sample(c("male","female","trans","other",NA), 1000, replace = TRUE))

# Names of bin./cat. variables
test_bin <- c("c","e")
test_cat <- c("a","f")

# Pre-process data
test_data <- convert(raw_data,
                       bin_cols = test_bin,
                       cat_cols = test_cat,
                       minmax_scale = TRUE)

# Overimpute - without plots
test_imp <- overimpute(test_data,
                       spikein = 0.3,
                       plot_vars = FALSE,
                       skip_plot = TRUE,
                       training_epochs = 10,
                       report_ival = 5)
}
}
