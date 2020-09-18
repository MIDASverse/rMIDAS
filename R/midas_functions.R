#' Instantiate Midas class
#'
#' Import Midas class into R environment, and instantiates passed parameters.
#' @keywords import
#' @param ... Arguments passed to the MIDAS class for instantiating network
#' @import reticulate
#' @export
#' @examples
#' midas_base <- import_midas()
import_midas <- function(...) {
  midas_base <- reticulate::import_from_path("midas_base", path = base::system.file("python", package = utils::packageName(), mustWork = TRUE))
  midas_class <- midas_base$Midas
  attr(midas_class, "class") <- "midas"
  return(midas_class(...))
}

#' Train an imputation model using Midas
#'
#' train() builds and runs a MIDAS neural network on the supplied data.
#' @keywords import
#' @param data A data.frame (or coercible) object, or an object of class `midas_pre` created from rMIDAS::convert()
#' @param binary_columns A vector of columns containing binary variables. NOTE: if `data` is a `midas_pre` object, this argument will be overwritten.
#' @param softmax_columns A list of lists, each internal list corresponding to a single categorical variable and containing names of the one-hot encoded variable names. NOTE: if `data` is a `midas_pre` object, this argument will be overwritten.
#' @param training_epochs An integer indicating the number of forward passes to conduct when running the model.
#' 
#' @param layer_structure A vector of integers, The number of nodes in each layer of the network (default = `c(256, 256, 256)`, denoting a three-layer network with 256 nodes per layer). Larger networks can learn more complex data structures but require longer training and are more prone to overfitting.
#' @param learn_rate A number, the learning rate \eqn{\gamma} (default = 0.0001), which controls the size of the weight adjustment in each training epoch. In general, higher values reduce training time at the expense of less accurate results.
#' @param input_drop A number between 0 and 1. The probability of corruption for input columns in training mini-batches (default = 0.8). Higher values increase training time but reduce the risk of overfitting. In our experience, values between 0.7 and 0.95 deliver the best performance.
#' @param seed An integer, the value to which \proglang{Python}'s pseudo-random number generator is initialized. This enables users to ensure that data shuffling, weight and bias initialization, and missingness indicator vectors are reproducible.
#' @param latent_space_size An integer, the number of normal dimensions used to parameterize the latent space.
#' @param cont_adj A number, weights the importance of continuous variables in the loss function
#' @param binary_adj A number, weights the importance of binary variables in the loss function
#' @param softmax_adj A number, weights the importance of categorical variables in the loss function
#' @param dropout_level A number between 0 and 1, determines the number of nodes dropped to "thin" the network
#' @param vae_layer Boolean, specifies whether to include a variational autoencoder layer in the network
#' @param vae_alpha A number, the strength of the prior imposed on the Kullback-Leibler divergence term in the variational autoencoder loss functions.
#' @param vae_sample_var A number, the sampling variance of the normal distributions used to parameterize the latent space.
#' @export
#' @return Returns object of class `midas` from which completed datasets can be drawn, using `rMIDAS::complete()`
#' @example inst/examples/basic_workflow.R
train <- function(data,
                   binary_columns = NULL,
                   softmax_columns = NULL,
                   training_epochs = 10L,
                   # MIDAS model parameters
                   layer_structure = c(256,256,256),
                   learn_rate = 0.0004,
                   input_drop = 0.8,
                   seed=123L,
                   latent_space_size = 4,
                   cont_adj= 1.0,
                   binary_adj= 1.0,
                   softmax_adj= 1.0,
                   dropout_level = 0.5,
                   vae_layer= FALSE,
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
                           vae_sample_var = vae_sample_var,
                           savepath= tempdir())

  transf_model = FALSE
  if (class(data) == "midas_pre") {
    binary_columns = data$bin_list
    softmax_columns = data$cat_lists
    transf_model = TRUE
  }

  mod_build <- mod_inst$build_model(na_to_nan(data$data),
                                    softmax_columns = softmax_columns,
                                    binary_columns = binary_columns)

  mod_train <- mod_build$train_model(training_epochs = training_epochs)

  if (transf_model) {
    mod_train$preproc <- data
  }
  
  return(mod_train)

}

#' Impute missing values using imputation model
#'
#' Having trained an imputation model, complete() produces `m` completed datasets, saved as a list.
#' @keywords impute
#' @param mid_obj object of class `midas`, the result of running `rMIDAS::impute()`
#' @param m integer number of completed datasets required
#' @param file path to save completed datasets. If `NULL`, completed datasets are only loaded into memory.
#' @param file_root character vector used as root of completed datasets if a filepath is passed to function. If no file_root is provided, saved datasets will be saved as "file/midas_impute_yymmdd_hhmmss_m.csv"
#' @param unscale boolean indicating whether to unscale any columns that were previously minmax scaled between 0 and 1
#' @param bin_label boolean indicating whether to add back labels for binary columns
#' @param cat_coalesce boolean indicating whether to decode the one-hot encoded categorical variables
#' @import data.table
#' @export
#' @example inst/examples/basic_workflow.R
complete <- function(mid_obj,
                     m=10L,
                     unscale = TRUE,
                     bin_label = TRUE,
                     cat_coalesce = TRUE,
                     file = NULL,
                     file_root = NULL) {

  if (!("midas_base.Midas" %in% class(mid_obj))) {
    stop("Trained midas object not supplied to 'mid_obj' argument")
  }

  if (!("preproc" %in% names(mid_obj))) {
    unscale = FALSE
    bin_label = FALSE
    cat_coalesce = FALSE
  }

  draws <- mid_obj$generate_samples(m = as.integer(m))$output_list

  ## Reverse pre-processing steps from convert():
  draws_post <- lapply(draws, function(df) {

    df <- as.data.table(df)

    # Undo scaling
    if (unscale) {
      num_params <- mid_obj$preproc$minmax_params
      num_cols <- names(num_params)

      for (j in num_cols) {

        set(df, j = j, value = undo_minmax(df[[j]], s_min = num_params[[j]]$min, s_max = num_params[[j]]$max))

      }

    }

    # Add binary labels

    if (bin_label) {

      bin_params <- mid_obj$preproc$bin_list
      bin_cols <- names(bin_params)

      for (j in bin_cols) {

        set(df, j = j, value = add_bin_labels(df[[j]], one = bin_params[[j]][1], zero = bin_params[[j]][2]))

      }

    }

    if (cat_coalesce) {

      cat_params <- mid_obj$preproc$cat_lists
      cat_cols <- mid_obj$preproc$cat_names

      for (i in 1:length(cat_cols)) {

        set(df,
            j = cat_cols[[i]],
            value = coalesce_one_hot(X = df[,cat_params[[i]], with = FALSE],
                                     var_name = cat_cols[i]))

      }

      # Remove one-hot columns
      df[,do.call("c",cat_params)] <- NULL

    }

    return(df)

  })


  # --- Save files

  if (!is.null(file)) {

    if (is.null(file_root)) {

      file_root <- paste0("midas_impute_",format(Sys.time(), "%y%m%d_%H%M%S"))

    }

    sapply(1:m, function (y) data.table::fwrite(x=draws_post[[y]], file = paste0(file,"/",file_root,"_",y,".csv")))
  }

  return(draws_post)
}

