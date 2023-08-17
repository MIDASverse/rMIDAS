## v0.5.0

In this version, we have:

* Added an automatic configuration for interfacing with Python, to ease the setup for users
* Addressed dependency issues and deprecation warnings in corresponding Python code
* Added additional examples that showcase rMIDAS' core functions
* Added a new vignette for running rMIDAS in headless mode
* Updated existing vignettes
* Updated accompanying YAML file to work on all major operating systems (including Apple silicon hardware)

## Test environments
* Local OS X install, R 4.3.0
* Fedora Linux, R-devel, clang, gfortran
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* Windows Server 2022, R-devel, 64 bit
* win-builder (devel and release)

## R CMD check results

There were no errors, or warnings, and 1 note.

The note refers to our use of messages in `.onLoad()`, specifically that we use 'readLine' to ask users whether they would like the package to auto-configure Python requirements. All other messages are wrapped in 'packageStartupMessage'.

The startup messages are designed to cater to both novice and experienced users. For non-power users they provide essential information without being redundant. For power users they are essentially bypassed. Moreover, this approach differentiates between interactive and non-interactive sessions, preventing sessions hanging when run on display-less servers.

The only write-out operation is a simple 'y/n' text file, which is crucial for rMIDAS package’s functionality.

## Downstream dependencies
There are no downstream dependencies currently.
