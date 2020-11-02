## rMIDAS 0.2

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
