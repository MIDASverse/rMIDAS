# rMIDAS
R package implementing multiple imputation method MIDAS (Python class [here](https://github.com/ranjitlall/MIDAS)) and accompanying statistical working paper [here](https://doi.org/10.33774/apsa-2020-3tk40-v3)

Based on the Python module, this package uses `reticulate` to bring MIDAS to R users.

This package also includes several convenience functions to increase the efficiency of imputation workflows:

* Easy pre-processing function `convert()` that applies one-hot encoding (required for MIDAS) and min-max scaling (improves convergence)
* Easy saving of complete datasets with `generate()`
* Optimisation for large data using `data.table` and `mltools` packages
* *Coming soon:* built-in post imputation analysis (using Rubin's rules).

## Basic imputation workflow

1. Read-in and pre-process missing data using `convert()`
2. Train the imputation model using `train()`
3. Generate completed datasets using `complete()`