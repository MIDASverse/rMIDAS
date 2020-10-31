#' Manually select python binary
#'
#' This function allows users to set a custom python binary from which the MIDAS algorithm is run.
#' Users comfortable with reticulate can configure Python manually using `reticulate::use_` functions, including pointing to a virtualenv or conda environment.
#' Note: If users wish to set a custom binary/environment, this must be completed prior to the first call to either `train()` or `complete()`. The same is true if users use the reticulate package directly.
#' If users wish to switch to a different Python binaries, R must be restarted prior to calling this function.
#' @param path Character string, path to python binary
#' @keywords setup
#' @export
#' @return Boolean indicating whether the custom python environment was activated.
set_python_env <- function(path) {

  set_complete <- FALSE

  if (!is.null(options("python_custom")$python_custom)) {
    warning("Python connection already initialised. To switch to a different Python install/virtualenv/conda environment, please restart R and try again.")
    return(set_complete)
  } else {

  set_py_attempt <- try(reticulate::use_python(python = path, required = TRUE),
                            silent = TRUE)

  }

  if ("try-error" %in% class(set_py_attempt)) {
    stop("Setting user-specified python environment '",path, "' failed.\n Please check the specified path and try again.")
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
    message("Python connection already initialised. To switch to a different Python install/virtualenv/conda environment, please restart R.")
    return(NULL)
  } else {

    if (is.null(options("python_custom")$python_custom)) {

      load_stat <- try(reticulate::use_python("python3", required  = FALSE))

      if ("try-error" %in% class (load_stat)) {
        stop("Unable to initialise Python and required packages.\n
            Please use set_python_env() to set the Python environment manually, then try again.")
      }

    }

    mid_py_setup()
    options("python_initialised" = TRUE)

  }
}

#' Manually set up Python connection
#'
#' This function allows users to initialise a custom Python configuration to run MIDAS, having manually set a Python version using `reticulate::use_python`, `reticulate::use_virtualenv`, `reticulate::use_condaenv`, or `reticulate::use_miniconda`.
#' @note This function is primarily aimed at users who wish to have complete control over configuring which Python version is used. This function call is **not** required if users do not manually configure their Python configuration via the `reticulate` package. This function is also not required if using the `rMIDAS::set_python_env()` function. If users set a custom binary/environment, this must be completed prior to the first call to either `train()` or `complete()`.
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
  py_dep <- c("matplotlib","numpy","pandas","tensorflow>=1.15","sklearn","os","random")
  py_pkgs <- gsub(">=1.15","",py_dep)

  py_pkg_load <- sapply(py_pkgs, function (py_pkg) try(reticulate::import(py_pkg, delay_load = TRUE),
                                                       silent = TRUE))

  missing_pkg <- sapply(py_pkg_load, function (x) ("try-error" %in% class(x)))
  missing_pkg <- py_dep[missing_pkg]

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
        pkg_install <- try(reticulate::py_install(py_pkg), silent = TRUE)

        if ("try-error" %in% class(pkg_install)) {
          stop("Unable to install package ", py_pkg, "\n")
        }
      }

    } else {
      stop("Unable to install packages.")
    }

    py_pkg_load <- sapply(py_pkgs, function (py_pkg) try(reticulate::import(py_pkg, delay_load = TRUE),
                                                         silent = TRUE))
    inst_check <- sum(sapply(py_pkg_load, function (x) ("try-error" %in% class(x))))

    if (inst_check != 0) {
      stop("\nUnable to load required packages")
    }
  }
}



