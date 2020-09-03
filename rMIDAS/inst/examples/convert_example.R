test_data = data.frame(a = sample(c("red","yellow","blue",NA),100, replace = TRUE),
                       b = 1:100,
                       c = sample(c("YES","NO",NA),100,replace=TRUE),
                       d = runif(100,1,10),
                       e = sample(c("YES","NO"), 100, replace = TRUE),
                       f = sample(c("male","female","trans","other",NA), 100, replace = TRUE))

test_bin <- c("c","e")
test_cat <- c("a","f")

test_data <- convert(test_data, 
                     bin_cols = test_bin, cat_cols = test_cat, 
                     minmax_scale = TRUE)
