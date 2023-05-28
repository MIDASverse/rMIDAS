.onLoad <- function(libname, pkgname) {
  
  options("python_custom" = NULL)
  options("python_initialised" = NULL)
  
  if (!interactive()) {
    user_input <- "n"
    packageStartupMessage("rMIDAS is loaded but its environment and dependencies are not set up automatically. \n Please read https://github.com/MIDASverse/rMIDAS for additional help on how to set up and configure your environment.")
  } else {
    user_input <- readline("Do you want rMIDAS to automatically set up a Python environment and its dependencies? Enter 'y' for Yes, or any other key for No : \n")
  }
  if(tolower(user_input) != "y") {
    packageStartupMessage("rMIDAS is loaded but its environment and dependencies are not set up automatically.\n Please read https://github.com/MIDASverse/rMIDAS for additional help on how to set up and configure your environment.")
  }
  if (tolower(user_input) == "y") {
    if (!requireNamespace("reticulate", quietly = TRUE)) {
      install.packages("reticulate")
    }
    
    library(reticulate)
    conda_env_name <- "rMIDAS_env"
    
    if (!conda_env_name %in% reticulate::conda_list()$name) {
      reticulate::conda_create(envname = conda_env_name)
    }
    
    reticulate::use_condaenv(conda_env_name, required = TRUE)
    
    python_version <- reticulate::py_config()$version
    python_version_numeric <- as.numeric(python_version)
    python_version_major <- floor(python_version_numeric)
    python_version_minor <- floor(python_version_numeric * 10) %% 10
    
    requirements_txt <- "numpy>=1.5
scikit-learn
matplotlib
pandas>=0.19
tensorflow_addons<0.20
statsmodels
scipy
"
    
    if (python_version_major == "3" && as.integer(python_version_minor) >= 8 && as.integer(python_version_minor) < 11) {
      if (Sys.info()["sysname"] == "Darwin" && Sys.info()["machine"] == "arm64") {
        requirements_txt <- paste0(requirements_txt, "tensorflow-macos<2.12.0")
      } else {
        requirements_txt <- paste0(requirements_txt, "tensorflow<2.12.0")
      }
    } else {
      if (Sys.info()["sysname"] == "Darwin" && Sys.info()["machine"] == "arm64") {
        requirements_txt <- paste0(requirements_txt, "tensorflow-macos>=1.10")
      } else {
        requirements_txt <- paste0(requirements_txt, "tensorflow>=1.10")
      }
    }
    
    requirements_file <- tempfile(fileext = ".txt")
    writeLines(requirements_txt, requirements_file)
    
    reticulate::conda_install(envname = conda_env_name, packages = NULL, pip = TRUE, pip_options = c("-r", requirements_file))
  }
}

.onAttach <- function(libname, pkgname) {
  
  packageStartupMessage("\n## \n",
                        "## rMIDAS: Multiple Imputation using Denoising Autoencoders \n",
                        "## Authors: Thomas Robinson and Ranjit Lall \n",
                        "## \n"
  )
}

.onUnload <- function(libpath) {
  # No action necessary
}
