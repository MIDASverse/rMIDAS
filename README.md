
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rMIDAS <img src='man/figures/logo.png' align="right" height="105" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rMIDAS)](https://cran.r-project.org/package=rMIDAS/)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![Last-changedate](https://img.shields.io/badge/last%20change-2023--08--16-yellowgreen.svg)](https://github.com/MIDASverse/rMIDAS/commits/master/)
[![R-CMD-check-Linux](https://github.com/MIDASverse/rMIDAS/actions/workflows/testlinux.yml/badge.svg)](https://github.com/MIDASverse/rMIDAS/actions/workflows/testlinux.yml)
[![R-CMD-check-macOS](https://github.com/MIDASverse/rMIDAS/actions/workflows/testmacos.yml/badge.svg)](https://github.com/MIDASverse/rMIDAS/actions/workflows/testmacos.yml)
[![R-CMD-check-Windows](https://github.com/MIDASverse/rMIDAS/actions/workflows/testwindows.yml/badge.svg)](https://github.com/MIDASverse/rMIDAS/actions/workflows/testwindows.yml)
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

**rMIDAS** is based on the Python package
[MIDASpy](https://github.com/MIDASverse/MIDASpy).

### Efficient handling of large data

rMIDAS also incorporates several features to streamline and improve the
the efficiency of multiple imputation analysis:

- Optimisation for large datasets using `data.table` and `mltools`
  packages
- Automatic reversing of all pre-processing steps prior to analysis
- Built-in regression function based on `glm` (applying Rubin’s
  combination rules)

### Background and suggested citations

For more information on MIDAS, the method underlying the software, see:

Lall, Ranjit, and Thomas Robinson. 2022. “The MIDAS Touch: Accurate and
Scalable Missing-Data Imputation with Deep Learning.” *Political
Analysis* 30, no. 2: 179-196. [Published
version](https://ranjitlall.github.io/assets/pdf/Lall%20and%20Robinson%202022%20PA.pdf).
[Accepted
version](http://eprints.lse.ac.uk/108170/1/Lall_Robinson_PA_Forthcoming.pdf).

Lall, Ranjit, and Thomas Robinson. 2023. “Efficient Multiple Imputation
for Diverse Data in Python and R: MIDASpy and rMIDAS.” *Journal of
Statistical Software*. [Accepted
version](https://ranjitlall.github.io/assets/pdf/jss4379.pdf) (in
press).

## Installation

rMIDAS is available on
[CRAN](https://cran.r-project.org/package=rMIDAS). To install the
package in R, you can use the following code:

``` r
install.packages("rMIDAS")
```

To install the latest development version, use the following code:

``` r
# install.packages("devtools")
devtools::install_github("MIDASverse/rMIDAS")
```

Note that rMIDAS uses the
[reticulate](https://github.com/rstudio/reticulate) package to interface
with Python. When the package is first loaded, it will prompt the user
on whether to set up a Python environment and its dependencies
automatically. Users that choose to set up the environment and
dependencies manually, or who use rMIDAS in headless mode can specify a
Python binary using `set_python_env()` (examples below). Currently,
Python versions from 3.6 to 3.10 are supported. For a custom Python
environment the following dependencies are also required:

- matplotlib
- numpy
- pandas
- scikit-learn
- scipy
- statsmodels
- tensorflow (\<2.12.0)
- tensorflow-addons (\<0.20.0)

Setting a custom Python install must be performed *before* training or
imputing data occurs. To manually set up a Python environment:

``` r
library(rMIDAS)
# Decline the automatic setup

# Point to a Python binary
set_python_env(x = "path/to/python/binary")

# Or point to a virtualenv binary
set_python_env(x = "virtual_env", type = "virtualenv")

# Or point to a conda environment
set_python_env(x = "conda_env", type = "conda")

# Now run rMIDAS::train() and rMIDAS::complete()...
```

You can also download the
[`rmidas-env.yml`](https://github.com/MIDASverse/rMIDAS/blob/master/rmidas-env.yml)
conda environment file from this repository to set up all dependencies
in a new conda environment. To do so, download the .yml file, navigate
to the download directory in your console and run:

``` bash
conda env create -f rmidas-env.yml
```

Then, prior to training a MIDAS model, make sure to load this
environment in R:

``` r
# First load the rMIDAS package
library(rMIDAS)
# Decline the automatic setup

set_python_env(x = "rmidas", type = "conda")
```

*Note*: **reticulate** only allows you to set a Python binary once per R
session, so if you wish to switch to a different Python binary, or have
already run `train()` or `convert()`, you will need to restart or
terminate R prior to using `set_python_env()`.

## Vignettes (including simple example)

**rMIDAS** is packaged with three vignettes:

1.  [`vignette("imputation_demo", "rMIDAS")`](https://github.com/MIDASverse/rMIDAS/blob/master/vignettes/imputation_demo.md)
    demonstrates the basic workflow and capacities of **rMIDAS**
2.  [`vignette("custom_python_versions", "rMIDAS")`](https://github.com/MIDASverse/rMIDAS/blob/master/vignettes/custom_python_versions.md)
    provides detailed guidance on configuring Python binaries and
    environments, including some troubleshooting tips
3.  [`vignette("use_server", "rMIDAS")`](https://github.com/MIDASverse/rMIDAS/blob/master/vignettes/use_server.md)
    provides guidance for running **rMIDAS** in headless mode

An additional example that showcases rMIDAS core functionalities can be
found
[here](https://github.com/MIDASverse/rMIDAS/blob/master/examples/rmidas_demo.md).

## Contributing to rMIDAS

Interested in contributing to **rMIDAS**? We are looking to hire a
research assistant to work part-time (flexibly) to help us build out new
features and integrate our software with existing machine learning
pipelines. You would be paid the standard research assistant rate at the
University of Oxford. To apply, please send your CV (or a summary of
relevant skills/experience) to <ranjit.lall@sjc.ox.ac.uk>.

## Getting help

rMIDAS is still in development, and we may not have caught all bugs. If
you come across any difficulties, or have any suggestions for
improvements, please raise an issue
[here](https://github.com/MIDASverse/MIDASpy/issues).
