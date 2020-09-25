
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rMIDAS <img src='man/figures/logo.png' align="right" height="105" />

<!-- badges: start -->

<!-- [![CRAN status](https://www.r-pkg.org/badges/version/dplyr)](https://cran.r-project.org/package=dplyr) -->

<!-- [![R build status](https://github.com/tidyverse/dplyr/workflows/R-CMD-check/badge.svg)](https://github.com/tidyverse/dplyr/actions?workflow=R-CMD-check) -->

<!-- [![Codecov test coverage](https://codecov.io/gh/tidyverse/dplyr/branch/master/graph/badge.svg)](https://codecov.io/gh/tidyverse/dplyr?branch=master) -->

<!-- [![R build status](https://github.com/tidyverse/dplyr/workflows/R-CMD-check/badge.svg)](https://github.com/tidyverse/dplyr/actions) -->

<!-- badges: end -->

## Overview

rMIDAS is a multiple imputation package for R using deep learning,
providing a simplified workflow to multiply impute and analyse data:

  - `convert()` carries out all necessary pre-processing steps
  - `train()` constructs and trains a MIDAS imputation model.
  - `complete()` generates multiple completed datasets from the trained
    model
  - `combine()` runs regression analysis across the complete data,
    following Rubin’s Rules.

rMIDAS is based on [MIDASpy](https://github.com/MIDASverse/MIDASpy).
More information about the underlying imputation method can be found
[here](https://doi.org/10.33774/apsa-2020-3tk40-v3).

### Efficient handling of large data

rMIDAS also incorporates several features to streamline and improve the
efficiency of multiple imputation analysis:

  - Optimisation for large datasets using `data.table` and `mltools`
    packages
  - Automatic reversing of all pre-processing steps prior to analysis
  - Built-in regression function based on `glm` (applying Rubin’s rules)

## Installation

rMIDAS should be available on CRAN very soon. In the meantime, you can
use the code below to install the development version:

``` r
# install.packages("devtools")
devtools::install_github("MIDASverse/rMIDAS")
```

Note that rMIDAS uses the
[reticulate](https://github.com/rstudio/reticulate) package to interface
with Python. Users must have Python 3.X installed in order to run MIDAS.
rMIDAS will automatically try to find Python 3 unless users specify
their own version, using the following code:

``` r
library(rMIDAS)

# Point to a Python binary
set_python_env(path = "path/to/python/binary", type = "auto", exact = FALSE)

# Point to a virtualenv binary
set_python_env(path = "path/to/virtual/env", type = "virtualenv", exact = FALSE)

# Point to a condaenv, where conda can be supplied to choose a specific executable
set_python_env(path = "path/to/conda/env", type = "auto", exact = FALSE, conda = "auto")
```

<!-- ## Usage -->

<!-- ```{r, message = FALSE} -->

<!-- ``` -->

## Getting help

rMIDAS is still in development, and we may not have caught all bugs. If
you come across any difficulties, or have any suggestions for
improvements, please raise an issue
[here](https://github.com/MIDASverse/MIDASpy/issues).
