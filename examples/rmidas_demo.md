rMIDAS demonstration
================

rMIDAS’s core functionalities are demonstrated here by using it to
impute missing responses to the 2018 Cooperative Congressional Election
Study (CCES), an electoral survey conducted in the United States whose
size and complexity poses computational difficulties for many existing
multiple imputation algorithms.

The full CCES has 525 columns and 60,000 rows, the latter corresponding
to individual survey respondents. After removing variables that either
require extensive preprocessing or are unhelpful for imputation purposes
— open-ended string variables, time indices, and ZIP code variables —
the dataset contains 349 columns. The vast majority of these variables
are categorical and must therefore be one-hot encoded for most multiple
imputation software packages — that is, each 1 × 60,000 categorical
variable with K unique classes must be expanded into a K × 60,000 matrix
of 1s and 0s — increasing their number to 1,914.

***Loading and preprocessing the data***

We begin by loading rMIDAS. If R is used interactively, then by calling
`library(rMIDAS)` a user will be prompted if rMIDAS should be set up
automatically.

``` r
library(rMIDAS)
set.seed(89)
```

We then read in the formatted CCES data and sort variables into
continuous, binary, and categorical types.

``` r
data_0 <- fread("cces_jss_format.csv")
```

We then preprocess the data into the format required by the MIDAS
algorithm using the `rMIDAS::convert()` function, which only requires
vectors of binary and categorical variables. We set
`minmax_scale = TRUE` to scale continuous variables between 0 and 1.

``` r
vals <- apply(data_0,2, function (x) length(unique(x)[!is.na(unique(x))]))
cont_vars <- c("citylength_1","numchildren","birthyr")
cat_vars <- names(vals)[vals > 2 & !(names(vals) %in% cont_vars)]
bin_vars <- names(vals)[vals == 2]
data_conv <- convert(data_0,
                     bin_cols = bin_vars,
                     cat_cols = cat_vars,
                     minmax_scale = TRUE)
```

***Imputation***

To train the MIDAS network, we pass our preprocessed data to the
`rMIDAS::train()` function and specify network hyperparameters. Unlike
in MIDASpy, we do not need to additionally declare categorical variables
and their classes with the `softmax_columns` argument.

``` r
data_train <- train(data_conv,
                    layer_structure= c(256,256),
                    vae_layer= FALSE,
                    seed= 89,
                    input_drop = 0.75,
                    training_epochs = 10)
```

    ## Initialising Python connection

We then generate 10 completed datasets using the `rMIDAS::complete()`
function, saving them in memory. The function returns scaled continuous
variables and one-hot encoded categorical variables to their original
form using the parameters saved in the preprocessing step. Unlike in the
MIDASpy demonstration, by default this function converts imputed
probabilities for binary variables into binary categories by taking
draws from a binomial distribution with $P(x = 1) = p$. Categorical
labels are similarly assigned by taking a weighted random draw using the
vector of predicted probabilities from the imputed data. This behavior
can be disabled by setting `fast = TRUE` when calling
`rMIDAS::complete()`, in which case binary variables are assigned 1 if
$p$ ≥ 0.5, and the label with the highest predicted probability is
chosen for categorical variables

``` r
imputations <- complete(data_train, m=10)
```

    ## Imputations generated. Completing post-imputation transformations.

***Analysis of completed datasets***

We estimate a linear probability model by means of the
`rMIDAS::combine()` function.

``` r
for (d in 1:10) {
  imputations[[d]]$age <- 2018 - imputations[[d]]$birthyr
  imputations[[d]]$CC18_415a <- ifelse(imputations[[d]]$CC18_415a == 1, 1, 0)}

combine("CC18_415a ~ age", imputations)
```

    ## No model family specified -- assuming gaussian model.

    ##          term     estimate    std.error statistic       df       p.value
    ## 1 (Intercept)  0.861297604 0.0060302023 142.83063 310.3369 3.757040e-285
    ## 2         age -0.004141295 0.0001148537 -36.05713 531.2022 7.103309e-145

Users can ensure exact reproducibility of analytical results by saving
completed datasets to disk. The trained rMIDAS model is also saved by
default in the R session directory.
