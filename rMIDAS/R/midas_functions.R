#' Instantiate Midas class
#'
#' Import Midas class into R environment, and instantiates passed parameters.
#' @keywords import
#' @export
#' @examples
#' midas_base <- import_midas()
import_midas <- function(...) {
  midas_base <- reticulate::import_from_path("midas_base", path = system.file("python", package = packageName(), mustWork = TRUE))
  midas_class <- midas_base$Midas
  attr(midas_class, "class") <- "midas"
  return(midas_class(...))
}

#' Impute missing data using Midas
#'
#' impute() builds and runs a MIDAS neural network on the supplied data.
#' @keywords import
#' @param data a data.frame (or coercible) object, or a 'midas_preproc' object created from rMIDAS::convert()
#' @param binary_columns a vector of columns containing binary variables. NOTE: if `data` is a `midas_preproc` object, this argument will be overwritten.
#' @param softmax_columns a list of lists, each internal list corresponding to a single categorical variable and containing names of the one-hot encoded variable names. NOTE: if `data` is a `midas_preproc` object, this argument will be overwritten.
#' @param training_epochs an integer indicating the number of forward passes to conduct when running the model.
#' @export
#' @return Returns object of class `midas` from which completed datasets can be drawn, using `rMIDAS::generate()`
#' @examples
#' midas_obj <- import_midas(layer_structure = c(256,256,256),
#'                           input_drop = 0.75,
#'                           learn_rate = 0.0005,
#'                           seed = 89)
impute <- function(data,
                   binary_columns = NULL,
                   softmax_columns,
                   training_epochs = 10L,
                   # MIDAS model parameters
                   layer_structure = c(256,256,256),
                   learn_rate = 0.0004,
                   input_drop = 0.8,
                   seed=123L,
                   vae_layer= FALSE,
                   latent_space_size = 4,
                   cont_adj= 1.0,
                   binary_adj= 1.0,
                   softmax_adj= 1.0,
                   dropout_level = 0.5,
                   vae_alpha = 1.0,
                   vae_sample_var = 1.0) {

  ## Parameters not integrated:
  # train_batch = 16,
  # savepath= 'tmp/MIDAS',
  # output_layers= 'reversed',
  # loss_scale= 1,
  # init_scale= 1,
  # individual_outputs= FALSE,
  # manual_outputs= FALSE,
  # output_structure= c(16, 16, 32),
  # weight_decay = 'default',
  # act = tf.nn.elu,
  # noise_type = 'bernoulli',
  # kld_min = 0.01) {

  mod_inst <- import_midas(layer_structure = as.integer(layer_structure),
                           learn_rate = learn_rate,
                           input_drop = input_drop,
                           seed = as.integer(seed),
                           vae_layer = vae_layer,
                           latent_space_size = as.integer(latent_space_size),
                           cont_adj = cont_adj,
                           binary_adj = binary_adj,
                           softmax_adj = softmax_adj,
                           dropout_level = dropout_level,
                           vae_alpha = vae_alpha,
                           vae_sample_var = vae_sample_var)

  if (class(data) == "midas_preproc") {
    binary_columns = data$bin_list
    softmax_columns = data$cat_lists
  }

  mod_build <- mod_inst$build_model(na_to_nan(data),
                                    softmax_columns = softmax_columns,
                                    binary_columns = binary_columns)

  mod_train <- mod_build$train_model(training_epochs = training_epochs)

  return(mod_train)

}

#' Generate
#'
#' Having generated an imputation model, generate() produces `m` datasets, saved as a list.
#' @keywords generate
#' @export
#' @examples
#' midas_obj <- impute(example_data,
#'                     layer_structure = c(128,128),
#'                     input_drop = 0.75,
#'                     learn_rate = 0.0005,
#'                     seed = 89)
#'
#' imp_data <- generate(midas_obj,
#'                      m = 5)
#'
generate <- function(mid_obj, m=10, file = NULL) {
  draws <- mid_obj$generate_samples(m = as.integer(m))

  dfs <- draws$output_list

  return(dfs)
}
