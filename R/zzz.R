custom_readline <- function(prompt, default = "skip") {
  if (interactive()) {
    return(readline(prompt))
  } else {
    return(default)
  }
}

custom_writelines <- function(input, con) {
  writeLines(input, con = con)
}

custom_packageStartupMessage <- function(msg) {
  messages <- list(
    msg1 = "rMIDAS is loaded. In headless mode its environment and dependencies need to be set up manually. Please read https://github.com/MIDASverse/rMIDAS for additional help on how to set up and configure your environment.",
    msg2 = "If you want to change your Python environment use 'reset_rMIDAS_env()' to reset your configuration. After resetting, you'll need to restart the R session and run 'library(rMIDAS)' again.",
    msg3 = "rMIDAS is loaded but its environment and dependencies are not set up automatically. Please read https://github.com/MIDASverse/rMIDAS for additional help on how to set up and configure your environment.",
    msg4 = "rMIDAS is being set up automatically.",
    msg5 = "rMIDAS is loaded. Please read https://github.com/MIDASverse/rMIDAS for additional help on how to set up and configure your environment. If you want to use a different Python environment use 'reset_rMIDAS_env()' to reset the your configuration. After resetting, you'll need to restart the R session and run 'library(rMIDAS)' again.",
    msg6 = "rMIDAS has been automatically set up.",
    msg7 = "rMIDAS is loaded. Please read https://github.com/MIDASverse/rMIDAS for additional help on how to set up and configure your environment. If you want to change your Python environment use 'reset_rMIDAS_env()' to reset your configuration. After resetting, you'll need to restart the R session and run 'library(rMIDAS)' again."
  )
  packageStartupMessage(messages[msg])
}

.onLoad <- function(libname, pkgname) {
  
  options("python_custom" = NULL)
  options("python_initialised" = NULL)
  
  if (requireNamespace("rappdirs", quietly = TRUE)) {
    config_dir <- rappdirs::user_config_dir(appname = "rMIDAS")
    if (!dir.exists(config_dir)) {
      dir.create(config_dir, recursive = TRUE)
    }
    config_file <- file.path(config_dir, ".rMIDAS_config")
    
    virtual_env_dir <- rappdirs::user_data_dir(appname = "rMIDAS")
    if (!dir.exists(virtual_env_dir)) {
      dir.create(virtual_env_dir, recursive = TRUE)
    }
  } else {
    stop("The 'rappdirs' package is required for rMIDAS. Please install it.")
  }
  
  if (!file.exists(config_file)) {
    if (!interactive()) {
      user_input <- "n"
      custom_packageStartupMessage("msg1")
      custom_packageStartupMessage("msg2")
    } else {
      user_input <- custom_readline("Do you want rMIDAS to automatically set up a Python environment and its dependencies? Enter 'y' for Yes, or any other key for No : \n", default = "n")
      custom_writelines(user_input, con = config_file)
      if(tolower(user_input) != "y") {custom_packageStartupMessage("msg3")}
      if(tolower(user_input) == "y") {custom_packageStartupMessage("msg4")}
    }
  } else {
    user_input <- readLines(con = config_file)[1]
    if(tolower(user_input) != "y") {
      custom_packageStartupMessage("msg5")
      custom_writelines(user_input, con = config_file)
    }
  }
  
  if (tolower(user_input) == "y") {
    Sys.setenv(WORKON_HOME = virtual_env_dir)
    virtual_env_name <- "rMIDAS_env_auto_setup"
    if (virtual_env_name %in% reticulate::virtualenv_list()) {
      reticulate::use_virtualenv(virtual_env_name, required = TRUE)
    } else {
      current_version <- reticulate::py_discover_config()$version
      matched_version <- NULL
      if (grepl("^3\\.(6|7|8|9|10).*|^3\\.(6|7|8|9|10)-dev$", current_version)) {
        matched_version <- current_version
      } else {
        matched_version <- "3.8.17"
        reticulate::install_python(version = matched_version, force = TRUE)
      }
      reticulate::virtualenv_create(envname = virtual_env_name, python_version = matched_version)
      reticulate::use_virtualenv(virtual_env_name, required = TRUE)
      python_version <- reticulate::py_discover_config()$version
      version_components <- strsplit(python_version, "\\.")[[1]]
      python_version_major <- as.numeric(version_components[1])
      python_version_minor <- as.numeric(version_components[2])
      
      requirements_txt <- "numpy>=1.5
scikit-learn
matplotlib
pandas>=0.19
tensorflow_addons<0.20.0
statsmodels
scipy
"
      
      if (python_version_major == 3 && as.integer(python_version_minor) >= 8 && as.integer(python_version_minor) < 11) {
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
      custom_writelines(requirements_txt, requirements_file)
      
      reticulate::py_install(envname = virtual_env_name, pip = TRUE, packages = c("-r", requirements_file))
      reticulate::py_config()
      reticulate::use_virtualenv(virtual_env_name, required = TRUE)
      custom_packageStartupMessage("msg6")
    }
    custom_packageStartupMessage("msg7")
  }
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("\n## \n",
                        "## rMIDAS: Multiple Imputation using Denoising Autoencoders \n",
                        "## Authors: Thomas Robinson and Ranjit Lall \n",
                        "## Please visit https://github.com/MIDASverse/rMIDAS for more information \n",
                        "## \n"
  )
}

.onDetach <- function(libpath) {
  # Nothing
}
