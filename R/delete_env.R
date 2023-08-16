#' Delete the rMIDAS Environment and Configuration
#'
#' Deletes both the virtual environment and the configuration file for the rMIDAS package.
#' After deletion, it is necessary to restart the R session and then load the rMIDAS package once more.
#' This will trigger the setup process again.
#'
#' @name delete_rMIDAS_env
#' @aliases delete_rMIDAS_env
#' @return A message indicating the completion of the deletion process.
#' @export

delete_rMIDAS_env <- function() {
  
  if (requireNamespace("rappdirs", quietly = TRUE)) {
    config_dir <- rappdirs::user_config_dir(appname = "rMIDAS")
    config_file <- file.path(config_dir, ".rMIDAS_config")
    
    virtual_env_dir <- rappdirs::user_data_dir(appname = "rMIDAS")
    virtual_env_name <- file.path(virtual_env_dir, "rMIDAS_env_auto_setup")
    
  } else {
    stop("The 'rappdirs' package is required to determine the directories. Please install it.")
  }
  
  if (dir.exists(virtual_env_name)) {
    unlink(virtual_env_name, recursive = TRUE)
    message("rMIDAS virtual environment deleted successfully.")
  } else {
    message("rMIDAS virtual environment not found.")
  }
  
  if (file.exists(config_file)) {
    file.remove(config_file)
    message("rMIDAS configuration file deleted successfully.")
  } else {
    message("rMIDAS configuration file not found.")
  }
  
  message("Please restart the R session and then load rMIDAS to set up the environment again.")
}