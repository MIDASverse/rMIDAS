## Test environments
* local OS X install, R 3.6.3
* ubuntu 16.04 (on rhub), R-release
* fedora (on rhub), R-devel
* windows server 2008 R2 SP1 (on rhub), R-devel
* win-builder (devel and release)

## Version 0.2.0

In this version I have:

* Improved handling of predicted probabilities, by adding a `fast` parameter to the `complete()` function, and the two post-processing helper functions `add_bin_labels()` and `coalesce_one_hot()`

* Added a vignette example

* Updated the Python code base to support Tensorflow 2.X

* Minor amendments to the README and DESCRIPTION files

* Replaced all instances of `cat()` with `message()` for better logging

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* Maintainer: 'Thomas Robinson <ts.robinson1994@gmail.com>'
  
  New submission
  
  Possibly mis-spelled words in DESCRIPTION:
  
    Autoencoders (2:44)
    Denoising (2:34)
    Lall (19:152)
    autoencoders (19:122)
    denoising (19:112)
    
All the words above are spelled correctly.

## Downstream dependencies
There are no downstream dependencies currently.
