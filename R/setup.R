#' Manually select python binary
#'
#' This function allows users to set a custom python binary, virtualenv or conda environment, from which the MIDAS algorithm is run.
#' Users comfortable with reticulate can configure Python manually using `reticulate::use_`.
#' Note: If users wish to set a custom binary/environment, this must be completed prior to the first call to either `train()` or `complete()`. The same is true if users use the reticulate package directly.
#' If users wish to switch to a different Python binaries, R must be restarted prior to calling this function.
#' @param x Character string, path to python binary, or directory of virtualenv, or name of conda environment
#' @param type Character string, specifies whether to set a python binary ("auto"), "virtualenv", or "conda"
#' @param ... Further arguments passed to `reticulate::use_condaenv()`
#' @keywords setup
#' @export
#' @return Boolean indicating whether the custom python environment was activated.
set_python_env <- function(x, type = "auto", ...) {

  set_complete <- FALSE

  if (!is.null(options("python_custom")$python_custom)) {
    warning("Python connection already initialised. To switch to a different Python install/virtualenv/conda environment, please restart R and try again.")
    return(set_complete)
  } else if (type == "auto") {

    set_py_attempt <- try(reticulate::use_python(python = x, required = TRUE),
                            silent = TRUE)

  } else if (type == "virtualenv") {

    set_py_attempt <- try(reticulate::use_virtualenv(virtualenv = x, required = TRUE),
                          silent = TRUE)

  } else if (type == "conda") {

    set_py_attempt <- try(reticulate::use_condaenv(condaenv = x, required = TRUE, ...),
                          silent = TRUE)

  } else {
    set_py_attempt <- "error"
    class(set_py_attempt) <- "try-error"
  }

  if (inherits(set_py_attempt,"try-error")) {
    stop("Setting user-specified python environment '",x, "' failed.
         Please check the specified path/environment and try again.")
  }

  set_complete <- TRUE
  options("python_custom" = TRUE)
  return(set_complete)

}

#' Initialise connection to Python
#'
#' Internal function. Checks if Python has already been initialised, and if not, completes the required setup to run the MIDAS algorithm.
#' This function is called automatically, and users should not call it directly.
#' To configure which Python install/environment/conda is used, see documentation for `set_python_env()`.
#' @keywords setup
#' @return NULL
python_init <- function() {

  if (!is.null(options("python_initialised")$python_initialised)) {
    warning("Python connection already initialised. To switch to a different Python install/virtualenv/conda environment, please restart R.")
    return(NULL)
  } else {

    if (is.null(options("python_custom")$python_custom)) {

      if (("r-reticulate" %in% virtualenv_list())) {
        load_stat <- try(reticulate::use_virtualenv("r-reticulate", required  = TRUE))
      } else {
        load_stat <- substr(py_config()$version[1],1,1)
      }

      if (inherits(load_stat, "try-error")) {

        stop("Unable to initialise Python and required packages.\n
            Please use set_python_env() to set the Python environment manually, then try again.")

      } else if (load_stat == "2") {

        stop("Unable to initialise Python3 as required for rMIDAS.\n
            Please use set_python_env() to set a Python3 environment manually, then try again.")

      }

    }

    mid_py_setup()
    options("python_initialised" = TRUE)

  }
}

#' Manually set up Python connection
#'
#' This function allows users to initialise a custom Python configuration to run MIDAS, having manually set a Python version using `reticulate::use_python`, `reticulate::use_virtualenv`, `reticulate::use_condaenv`, or `reticulate::use_miniconda`.
#' @note This function is primarily for users who wish to have complete control over configuring Python versions and environments.
#'
#' This function call is **not** required if users either use the `rMIDAS::set_python_env()` function or leave settings at their default.
#'
#' If users set a custom binary/environment, this must be completed prior to the first call to either `train()` or `complete()`.
#' @keywords setup
#' @export
#' @return NULL
midas_setup <- function() {
  if (!is.null(options("python_initialised")$python_initialised)) {
    message("Python connection already initialised. To switch to a different Python install/virtualenv/conda environment, please restart R.")
    return(NULL)
  } else {
    message("Setting up Python version for use with MIDAS\n")
    mid_py_setup()
    options("python_initialised" = TRUE)
    return(NULL)
  }
}

#' Configure python for MIDAS imputation
#'
#' This helper function checks if the required Python dependencies are installed, and if not, checks with user before installing them.
#' Users should not call this function directly. Users can set a custom python install using `set_python_env()` so long as this is done prior to the first call to `train()` or `complete()`.
#' @keywords setup
#' @return NULL
mid_py_setup <- function() {

  py_dep <- c("matplotlib","numpy","pandas","tensorflow","sklearn","os","random", "tensorflow_addons")
  py_pkgs <- py_dep
  # py_pkgs <- gsub(">=1.15","",py_dep)
  # py_pkgs <- gsub(">=0.11","",py_pkgs)

  py_pkg_load <- sapply(py_pkgs, function (py_pkg) try(reticulate::import(py_pkg, delay_load = FALSE),
                                                       silent = TRUE))

  missing_pkg <- sapply(py_pkg_load, function (x) inherits(x, "try-error"))
  missing_pkg <- py_dep[missing_pkg]

  if ("sklearn" %in% missing_pkg) {
    missing_pkg[missing_pkg == "sklearn"] <- "scikit-learn"
  }

  if (length(missing_pkg) >= 1) {
    message("\nThe following packages need to be installed: ", paste0(missing_pkg, sep = "  "))
    ask <- 1
    usr_response <- readline(prompt="Are you happy to proceed? [Y/N]: ")

    while (!(tolower(usr_response) %in% c("y","n")) & ask <= 5) {
      usr_response <- readline(prompt="Invalid input. Please enter either 'Y' or 'N': ")
      ask <- ask + 1
    }

    if (tolower(usr_response) == "y") {

      for (py_pkg in missing_pkg) {
        message("\nInstalling missing python dependency: ",py_pkg)
        pkg_install <- try(reticulate::py_install(py_pkg,
                                                  pip = TRUE,
                                                  python_version = "<3.9"),
                           silent = TRUE)

        if (inherits(pkg_install, "try-error")) {
          stop("Unable to install package ", py_pkg, "\n")
        }
      }

    } else if (tolower(usr_response) == "n") {

      stop("Install declined by user. rMIDAS cannot proceed without Python dependencies\n")

    } else {
      stop("Unable to install packages\n")
    }

    message("Loading new installations...\n")

    py_v <- substr(py_config()$version[1],1,3)

    # Catch error from reticulate conda config not updating on Python 3.9 downgrade
    if (py_v == "3.9") {

      warning("Packages installed but the R session needs to be restarted before proceeding.
              Please restart R then call set_py_env('your_conda_name', type = 'conda').
              rMIDAS will then be ready to train and impute missing data.")

    } else {

      py_pkg_load <- sapply(py_pkgs, function (py_pkg) try(reticulate::import(py_pkg, delay_load = FALSE),
                                                           silent = TRUE))

      inst_check <- sum(sapply(py_pkg_load, function (x) inherits(x,"try-error")))

      if (inst_check != 0) {
        stop("\nUnable to load required packages after install")
      }

    }

  }

}

