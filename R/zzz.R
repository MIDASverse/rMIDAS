.onLoad <- function(libname, pkgname) {

  options("python_custom" = NULL)
  options("python_initialised" = NULL)

}

.onAttach <- function(libname, pkgname) {

  packageStartupMessage("\n## \n",
                        "## rMIDAS: Multiple Imputation using Denoising Autoencoders \n",
                        "## Authors: Thomas Robinson and Ranjit Lall \n",
                        "## Please visit https://github.com/MIDASverse/rMIDAS for more information \n",
                        "## \n"
  )

}
