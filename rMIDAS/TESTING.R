library(devtools)
library(roxygen2)
library(reticulate)
library(data.table)
library(mltools)

data = data.frame(a = sample(c("red","yellow","blue",NA),100, replace = TRUE),
                  b = 1:100,
                  c = sample(c("YES","NO",NA),100,replace=TRUE),
                  d = runif(100),
                  e = sample(c("YES","NO"), 100, replace = TRUE),
                  f = sample(c("male","female","trans","other",NA), 100, replace = TRUE))


bin_cols <- c("c","e")
cat_cols <- c("a","b","f")
data_oh <- convert(data, bin_cols, cat_cols)
