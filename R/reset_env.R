#' Reset the rMIDAS Environment Configuration
#'
#' Resets the configuration for the rMIDAS package by deleting the configuration file. 
#' Once the configuration is reset, it is necessary to restart the R session 
#' and then load the rMIDAS package once more. 
#'
#' @name reset_rMIDAS_env
#' @aliases reset_rMIDAS_env
#' @return A message indicating the completion of the reset process. 
#' @export

reset_rMIDAS_env <- function() {
  # Use rappdirs to get the appropriate user configuration directory
  if (requireNamespace("rappdirs", quietly = TRUE)) {
    config_dir <- rappdirs::user_config_dir(appname = "rMIDAS")
    config_file <- file.path(config_dir, ".rMIDAS_config")
  } else {
    stop("The 'rappdirs' package is required to determine the configuration directory. Please install it.")
  }
  
  if (!file.exists(config_file)) {
    stop("rMIDAS config file doesn't exist.")
  }
  
  # Option 1: Delete the entire config file.
  file.remove(config_file)
  
  # OR Option 2: Overwrite the config file with a default or empty value.
  # writeLines("", con = config_file)
  
  message("rMIDAS configuration reset. Please restart the R session and then load rMIDAS again.")
}