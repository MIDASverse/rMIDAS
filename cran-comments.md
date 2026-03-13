## v1.0.1

This version marks `rMIDAS` as deprecated in favor of `rMIDAS2`.
The package remains on CRAN for existing users, but the documentation,
package help, startup banner, and vignettes now point users to the
successor package and its migration guide.

## Test environments
* Local macOS Sequoia 15.7.3, R 4.5.2
* macOS devel, R 4.6.0
* Windows release, R 4.5.2

## R CMD check results

There were no errors, warnings, or notes on a clean local
`R CMD check --as-cran` run.

After submission of `rMIDAS_1.0.1.tar.gz`, the CRAN incoming pretest on
Debian reported one NOTE in `tests`:
"Running `testthat.R` had CPU time 3.5 times elapsed time".
The test harness now explicitly limits BLAS/OpenMP/TensorFlow/data.table
threads to 1 during checks to avoid multithreaded CPU inflation.

## Downstream dependencies
There are no downstream dependencies currently.
