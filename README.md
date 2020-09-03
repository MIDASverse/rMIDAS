# rMIDAS
R package implementing multiple imputation method MIDAS (base code [here](https://github.com/ranjitlall/MIDAS)).

Building on the Python module, this package uses `reticulate` to call the TensorFlow-based imputation model.

This package also includes several convenience functions to increase the efficiency of imputation workflows using MIDAS, including pre-processing, dataset generation, and basic multiple imputation analysis (using Rubin's rules).

This package is optimised for large datasets by utilising the `data.table` and `mltools` packages to make efficient transformations on very large data files.
