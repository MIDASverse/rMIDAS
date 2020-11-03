
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rMIDAS <img src='man/figures/logo.png' align="right" height="105" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rMIDAS)](https://cran.r-project.org/package=rMIDAS)
[![R build
status](https://github.com/MIDASverse/rMIDAS/workflows/R/badge.svg)](https://github.com/tidyverse/dplyr/actions?workflow=R)
[![R build
status](https://github.com/tsrobinson/rMIDAS/workflows/R-CMD-check/badge.svg)](https://github.com/MIDASverse/rMIDAS/actions)
<!-- badges: end -->

## Overview

**rMIDAS** is an R package for multiply imputing missing data using an
accurate and efficient algorithm based on deep learning methods. The
package provides a simplified workflow for imputing and then analyzing
data:

  - `convert()` carries out all necessary preprocessing steps
  - `train()` constructs and trains a MIDAS imputation model
  - `complete()` generates multiple completed datasets from the trained
    model
  - `combine()` estimates regression models on the complete data,
    employing Rubin’s combination Rules

**rMIDAS** is based on the Python class
[MIDASpy](https://github.com/MIDASverse/MIDASpy).

### Efficient handling of large data

rMIDAS also incorporates several features to streamline and improve the
the efficiency of multiple imputation analysis:

  - Optimisation for large datasets using `data.table` and `mltools`
    packages
  - Automatic reversing of all pre-processing steps prior to analysis
  - Built-in regression function based on `glm` (applying Rubin’s
    combination rules)

### Background on method

For more information on the underlying multiple imputation method,
MIDAS, see:

Lall, Ranjit, and Thomas Robinson. 2020. “Applying the MIDAS Touch: How
to Handle Missing Values in Large and Complex Data.” APSA Preprints.
<https://doi.org/10.33774/apsa-2020-3tk40-v3>

## Installation

rMIDAS is now available on
[CRAN](https://cran.r-project.org/package=rMIDAS). To install the
package in R, you can use the following code:

``` r
install.packages("rMIDAS")
```

To install the latest development version, please use the following
code:

``` r
# install.packages("devtools")
devtools::install_github("MIDASverse/rMIDAS")
```

Note that rMIDAS uses the
[reticulate](https://github.com/rstudio/reticulate) package to interface
with Python. Users must have Python 3.5 - 3.8 installed in order to run
MIDAS (Python 3.9 is not yet supported). rMIDAS will automatically try
to set up a Python configuration unless users specify their own version
using `set_python_env()` (examples below). Setting a custom Python
install must be performed *before* training or imputing data occurs:

``` r
library(rMIDAS)

# Point to a Python binary
set_python_env(python = "path/to/python/binary")

# Point to a virtualenv binary
set_python_env(python = "virtual_env", type = "virtualenv")

# Point to a condaenv, where conda can be supplied to choose a specific executable
set_python_env(python = "conda_env", type = "condaenv", conda = "auto")

# Now run rMIDAS::train() and rMIDAS::complete()...
```

## Vignettes (including demo)

**rMIDAS** is packaged with two vignettes:

1.  `vignette("impute-demo", "rMIDAS")` demonstrates the basic workflow
    and capacities of **rMIDAS**
2.  `vignette("custom-python", "rMIDAS")` provides detailed guidance on
    configuring Python binaries and environments, including some
    troubleshooting tips

## Getting help

rMIDAS is still in development, and we may not have caught all bugs. If
you come across any difficulties, or have any suggestions for
improvements, please raise an issue
[here](https://github.com/MIDASverse/MIDASpy/issues).
