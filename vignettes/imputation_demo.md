Imputing missing data using rMIDAS
================

This vignette provides a brief demonstration of **rMIDAS**. We show how
to use the package to impute missing values in the [*Adult
Census*](https://github.com/MIDASverse/MIDASpy/blob/master/Examples/adult_data.csv)
dataset, which is commonly used for benchmarking machine learning tasks.

## Ensure your system is correctly configured

**rMIDAS** relies on Python to implement the MIDAS imputation algorithm,
so a Python environment needs to be installed on your machine.
Currently, Python versions from 3.6 to 3.10 are supported. When the
package is first loaded, it will prompt the user on whether to set up a
Python environment and its dependencies automatically. Users that choose
to set up the environment and dependencies manually, or who use
**rMIDAS** in headless mode can specify a Python binary using
`set_python_env()`. For additional help on manually setting up a Python
environment and its dependencies please refer to our other vignettes
(*Using custom Python versions* and *Running rMIDAS on a server
instance*) or visit the [rMIDAS
GitHub](https://github.com/MIDASverse/rMIDAS/) page.

## Loading the data

Once **rMIDAS** is initialized, we can load our data. For the purpose of
this example, we’ll use a subset of the Adult data:

``` r
library(rMIDAS)

adult <- read.csv("https://raw.githubusercontent.com/MIDASverse/MIDASpy/master/Examples/adult_data.csv",
                  row.names = 1)[1:1000,]
```

As the dataset has a very low proportion of missingness (one of the
reasons it is favored for machine learning tasks), we randomly set 10%
of observed values as missing in each column using the **rMIDAS**’
`add_missingness()` function:

``` r
set.seed(89)

adult <- add_missingness(adult, prop = 0.1)
```

Next, we make a list of all categorical and binary variables, before
preprocessing the data for training using the `convert()` function.
Setting the `minmax_scale` argument to `TRUE` ensures that continuous
variables are scaled between 0 and 1, which can substantially improve
convergence in the training step. All pre-processing steps can be
reversed after imputation:

``` r
adult_cat <- c('workclass','marital_status','relationship','race','education','occupation','native_country')
adult_bin <- c('sex','class_labels')

# Apply rMIDAS preprocessing steps
adult_conv <- convert(adult, 
                      bin_cols = adult_bin, 
                      cat_cols = adult_cat,
                      minmax_scale = TRUE)
```

The data are now ready to be fed into the MIDAS algorithm, which
involves a single call of the `train()` function. At this stage, we
specify the dimensions, input corruption proportion, and other
hyperparameters of the MIDAS neural network as well as the number of
training epochs:

``` r
# Train the model for 20 epochs
adult_train <- train(adult_conv,
                       training_epochs = 20,
                       layer_structure = c(128,128),
                       input_drop = 0.75,
                       seed = 89)
```

    ## Initialising Python connection

Once training is complete, we can generate any number of completed
datasets using the `complete()` function (below we generate 10). The
completed dataframes can also be saved as ‘.csv’ files using the `file`
and `file_root` arguments (not demonstrated here). By default,
`complete()` unscales continuous variables and converts binary and
categorical variables back to their original form.

Since the MIDAS algorithm returns predicted probabilities for binary and
categorical variables, imputed values of such variables can be generated
using one of two options. When `fast = FALSE` (the default),
`complete()` uses the predicted probabilities for each category level to
take a weighted random draw from the set of all levels. When
`fast = TRUE`, the function selects the level with the highest predicted
probability. If completed datasets are very large or `complete()` is
taking a long time to run, users may benefit from choosing the latter
option:

``` r
# Generate 10 imputed datasets
adult_complete <- complete(adult_train, m = 10)
```

    ## Imputations generated. Completing post-imputation transformations.

``` r
# Inspect first imputed dataset:
head(adult_complete[[1]])
```

    ##        age   fnlwgt education_num capital_gain capital_loss hours_per_week
    ## 1 39.00000  77516.0      10.29917         2174       0.0000             40
    ## 2 35.19139  83311.0      13.00000            0       0.0000             13
    ## 3 38.00000 215646.0       9.00000            0       0.0000             40
    ## 4 53.00000 234721.0       7.00000            0      15.6308             40
    ## 5 33.40710 338409.0      13.00000            0       0.0000             40
    ## 6 37.00000 217087.1      14.00000            0       0.0000             40
    ##      sex class_labels        workclass     marital_status  relationship  race
    ## 1   Male        <=50K        State-gov      Never-married Not-in-family White
    ## 2   Male        <=50K Self-emp-not-inc Married-civ-spouse       Husband Black
    ## 3   Male        <=50K          Private           Divorced Not-in-family White
    ## 4   Male        <=50K          Private Married-civ-spouse       Husband Black
    ## 5 Female        <=50K          Private Married-civ-spouse          Wife Black
    ## 6 Female        <=50K          Private Married-civ-spouse          Wife White
    ##   education        occupation native_country
    ## 1 Bachelors      Adm-clerical  United-States
    ## 2   7th-8th   Exec-managerial  United-States
    ## 3   HS-grad Handlers-cleaners  United-States
    ## 4      11th Handlers-cleaners          India
    ## 5 Bachelors    Prof-specialty           Cuba
    ## 6   HS-grad   Exec-managerial  United-States

Finally, the `combine()` function allows users to estimate regression
models on the completed datasets with Rubin’s combination rules. This
function wraps the `glm()` package, whose arguments can be used to
select different families of estimation methods (gaussian/OLS, binomial
etc.) and to specify other aspects of the model:

``` r
# Estimate logit model on 10 completed datasets (using Rubin's combination rules)
adult_model <- combine("class_labels ~ hours_per_week + sex", 
                    adult_complete,
                    family = stats::binomial)

adult_model
```

    ##             term    estimate  std.error statistic       df      p.value
    ## 1    (Intercept)  3.60381784 0.37801526  9.533525 153.8703 3.231271e-17
    ## 2 hours_per_week -0.04751554 0.00834382 -5.694698 135.4073 7.360524e-08
    ## 3        sexMale -0.73352237 0.18632148 -3.936864 778.4708 8.994749e-05
