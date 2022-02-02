# rMIDAS 0.4.0 

* Minor changes to fix R CMD check --run-donttest issue


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
