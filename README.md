
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rMIDAS <img src='man/figures/logo.png' align="right" height="105" />

<!-- badges: start -->

[![R build
status](https://github.com/tsrobinson/rMIDAS/workflows/R-CMD-check/badge.svg)](https://github.com/MIDASverse/rMIDAS/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/rMIDAS)](https://cran.r-project.org/package=rMIDAS)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![Last-changedate](https://img.shields.io/badge/last%20change-2021--01--29-yellowgreen.svg)](https://github.com/MIDASverse/rMIDAS/commits/master)
<!-- badges: end -->

## Overview

**rMIDAS** is an R package for accurate and efficient multiple
imputation using deep learning methods. The package provides a
simplified workflow for imputing and then analyzing data:

  - `convert()` carries out all necessary preprocessing steps
  - `train()` constructs and trains a MIDAS imputation model
  - `complete()` generates multiple completed datasets from the trained
    model
  - `combine()` runs regression analysis across the complete data,
    following Rubin’s combination rules

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

Lall, Ranjit, and Thomas Robinson. Forthcoming. “The MIDAS Touch: Accurate and Scalable Missing-Data Imputation with Deep Learning.” _Political Analysis_.
<http://eprints.lse.ac.uk/108170/1/Lall_Robinson_PA_Forthcoming.pdf>

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

# Or point to a virtualenv binary
set_python_env(python = "virtual_env", type = "virtualenv")

# Or point to a condaenv, where conda can be supplied to choose a specific executable
set_python_env(python = "conda_env", type = "condaenv", conda = "auto")

# Now run rMIDAS::train() and rMIDAS::complete()...
```

## Vignettes (including example)

**rMIDAS** is packaged with two vignettes:

1.  [`vignette("imputation_demo",
    "rMIDAS")`](https://github.com/MIDASverse/rMIDAS/blob/master/vignettes/imputation_demo.Rmd)
    demonstrates the basic workflow and capacities of **rMIDAS**
2.  [`vignette("custom_python_versions",
    "rMIDAS")`](https://github.com/MIDASverse/rMIDAS/blob/master/vignettes/custom_python_versions.Rmd)
    provides detailed guidance on configuring Python binaries and
    environments, including some troubleshooting tips

## Getting help

rMIDAS is still in development, and we may not have caught all bugs. If
you come across any difficulties, or have any suggestions for
improvements, please raise an issue
[here](https://github.com/MIDASverse/MIDASpy/issues).
