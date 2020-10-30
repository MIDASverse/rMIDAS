## rMIDAS 0.2

* rMIDAS now fully supports both Tensorflow 1.X and 2.X

* Added a vignette with a basic usage example

* Added a `fast` parameter to the `complete()` function, giving users more flexibility on how to handle predicted probabilities for categorical and binary variables.

* Defined function `add_missingness()` to spike-in missingness for examples

* Minor amendments to the README

* Minor changes to DESCRIPTION including title and description fields

* Replaced all instances of `cat()` with `message()` for better logging

# rMIDAS 0.1

* First release including all core functionality
* VAE and overimputation diagnostic tests included
* Easy to use pre/post-processing of data
* Multiple imputation wrapper of `glm()' for in-built analysis of completed data
