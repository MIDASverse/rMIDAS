.onLoad <- function(libname, pkgname) {
  reticulate::use_python("~/.virtualenvs/r-reticulate/bin/python3", required  = TRUE)
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

#' A test function
#'
#' This function prints a test string.
#' @param test_string Vector to be printed
#' @keywords test
#' @export
#' @examples
#' test_function()

test_function <- function(test_string) {
  print(test_string)
}