.onLoad <- function(libname, pkgname) {

  load_stat <- try(reticulate::use_python("python3", required  = FALSE))

  if (!("try-error" %in% class (load_stat))) {
    mid_py_setup()
  } else {
    warning("Unable to initialise Python and required packages.\n
            Please use set_python_env() to set the Python environment manually.")
  }
}


#' Configure python for MIDAS imputation
#'
#' This function checks if the required Python dependencies are installed, and if not, checks with user before installing them.
#' This function is called automatically within `set_python_env`, and should only need to be used when manually configuring python installs using reticulate.
#' @keywords setup
mid_py_setup <- function() {
  py_dep <- c("matplotlib","numpy","pandas","tensorflow==1.15","sklearn","random")
  py_pkgs <- gsub("==1.15","",py_dep)

  py_pkg_load <- sapply(py_pkgs, function (py_pkg) try(reticulate::import(py_pkg, delay_load = TRUE),
                                                       silent = TRUE))

  missing_pkg <- sapply(py_pkg_load, function (x) ("try-error" %in% class(x)))
  missing_pkg <- py_dep[missing_pkg]

  if (length(missing_pkg) >= 1) {
    cat("\nThe following packages need to be installed: ", paste0(missing_pkg, sep = "  "))
    ask <- 1
    usr_response <- readline(prompt="Are you happy to proceed? [Y/N]: ")

    while (!(tolower(usr_response) %in% c("y","n")) & ask <= 5) {
      usr_response <- readline(prompt="Invalid input. Please enter either 'Y' or 'N': ")
      ask <- ask + 1
    }

    if (tolower(usr_response) == "y") {

      for (py_pkg in missing_pkg) {
        cat("\nInstalling missing python dependency: ",py_pkg)
        reticulate::py_install(py_pkg)
      }

    } else {
      stop("\nUnable to install packages")
    }

    py_pkg_load <- sapply(py_pkgs, function (py_pkg) try(reticulate::import(py_pkg, delay_load = TRUE),
                                                         silent = TRUE))
    inst_check <- sum(sapply(py_pkg_load, function (x) ("try-error" %in% class(x))))

    if (inst_check != 0) {
      stop("\nUnable to load required packages")
    }
  }
}

#' Configure python version
#'
#' This function allows users to set a custom python binary, virtualenv, or Conda environment.
#'
#' Users comfortable with reticulate may wish to configure Python manually using reticulate, and then call `mid_py_setup()` to check/install required Python dependencies for rMIDAS.
#' @param type Character string, one of 'auto' (for python binary),'virtualenv', or 'condaenv'
#' @param path Character string, path to python binary if `type == "auto"`, path to virtualenv if `type == "virtualenv"`, or the name of a Conda environment if `type=="condaenv`
#' @param exact Boolean. If `TRUE` then only load exact match from `path`, otherwise allow reticulate to scan for other versions.
#' @param ... Further argument passed to reticulate::use_condaenv() for `conda` executable if `type == "condaenv"`.
#' @keywords setup
#' @export
#' @examples
#' \dontrun{
#' set_python_env(path = "~/.path/to/python/binary", type = "auto", exact = FALSE)
#' }
set_python_env <- function(path, type = "auto", exact = FALSE,...) {

  if (type == "auto") {
    set_py_attempt <- try(reticulate::use_python(python = path, required = exact),
                          silent = TRUE)
  } else if (type == "virtualenv") {
    set_py_attempt <- try(reticulate::use_virtualenv(virtualenv = path, required = exact),
                          silent = TRUE)
  } else if (type == "condaenv") {
    set_py_attempt <- try(reticulate::use_condaenv(condaenv = path, required = exact, ...),
                          silent = TRUE)
  } else {
    stop("Type of configuration not recognised; 'type' should be one of 'auto','virtualenv','condaenv'")
  }


  if ("try-error" %in% class(set_py_attempt)) {
    stop("Setting user-specified python environment '",path, "' failed.\n Please check the specified path and try again.")
  } else {
    message("Proceeding to check/install Python package dependencies.")
    mid_py_setup()
  }
}

