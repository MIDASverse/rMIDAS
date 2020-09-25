## Test environments
* local OS X install, R 3.6.3
* ubuntu 16.04 (on rhub), R-release
* fedora (on rhub), R-devel
* windows server 2008 R2 SP1 (on rhub), R-devel
* win-builder (devel and release)

## Resubmission

This is a resubmission. In this version I have:

* Added single quotation marks to all software and API names in the Description field of DESCRIPTION

* Replaced all instances of \\dontrun{} with \\donttest{}
    - Removed example from `set_python_env()` since this code was designed to fail, and matches \\usage so was redundant
    - Removed \\dontrun{} from `na_to_nan()` function 

* Added \\value tags to all exported functions

    - Added boolean return value to `set_python_env()` for consistency
    
* Added export tags where missing, and checked all functions to ensure those without export do not have examples.

* Added copyright holder tags to Authors@R field in DESCRIPTION

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
