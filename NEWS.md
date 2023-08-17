# rMIDAS 0.4

## v0.5.0
* rMIDAS now includes an automatic setup that prompts the user on whether to automatically set up a Python environment and its dependencies
* Addressed dependency issues and deprecation warnings (rather a Python update than R)
* An additional .Rmd example that showcases rMIDAS core functions
* Added a new vignette for running rMIDAS in headless mode, along with updates to the existing vignettes
* Updated the accompanying YAML environment file that works on all major operating systems (including macOS running Apple silicon hardware)
* Expanded our GitHub Actions workflow to also perform R-CMD-checks on macOS and Windows systems
* Updated README file

## v0.4.2
* Added headless functionality to matplotlib calls in Python
* Updated conda setup file
* Minor updates to underlying Python code to address deprecation issues

## v0.4.1
* Disabled Tensorflow deprecation warnings as default (as Python rather than R warning)
* Updated accompanying YAML for easier Conda setup
* Added `no-binary` pip install to YAML to resolve BLAS issues on Macs

## v0.4

* `python` argument in `set_python_env` renamed to `x` for clarity
* Minor fixes including remedying bug in `complete()` function
* Improved documentation

# rMIDAS 0.3

* Minor updates to underlying Python code to mirror MIDASpy v1.2.1
* Added NULL defaults to cat_cols and bin_cols parameters within `rMIDAS::convert()`
* Overimputation legend now plotted in bottom-right corner of figure
* Minor changes to README

# rMIDAS 0.2

* rMIDAS now fully supports both Tensorflow 1.X and 2.X
* Added two vignettes for demonstrating imputation workflow and configuring Python installs/environments
* Streamlined handling of Python configuration and interface with **reticulate**
* Added a `fast` parameter to the `complete()` function, giving users more flexibility on how to handle predicted probabilities for categorical and binary variables.
* Added function `add_missingness()` to spike-in missingness for examples
* Minor changes to README
* Minor changes to DESCRIPTION including title and description fields
* Replaced all instances of `cat()` with `message()` for better logging
* Bug fixes related to GitHub issues

# rMIDAS 0.1

* First release including all core functionality
* VAE and overimputation diagnostic tests included
* Easy to use pre/post-processing of data
* Multiple imputation wrapper of `glm()' for in-built analysis of completed data
