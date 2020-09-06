# rMIDAS
R package implementing multiple imputation method MIDAS (Python class [here](https://github.com/ranjitlall/MIDAS)) and accompanying statistical working paper [here](https://doi.org/10.33774/apsa-2020-3tk40-v3).

Based on the Python module, this package uses `reticulate` to bring MIDAS to R users.

This package simplifies the imputation workflow to ensure MIDAS is user-friendly and efficient:

* Single pre-processing step that applies one-hot encoding, binary variable formatting, and name extraction (required for MIDAS), and min-max scaling to improve algorithm convergence
* Easy generation of complete datasets with `generate()`
* Optimisation for large datasets using `data.table` and `mltools` packages
* Automated reversing of all pre-processing steps prior to analysis
* Built-in regression function based on `glm` (applying Rubin's rules) 

## Basic imputation workflow

1. Read-in and pre-process missing data using `convert()`
2. Train the imputation model using `train()`
3. Generate completed datasets using `complete()`
4. Estimate regression parameters using `combine()`