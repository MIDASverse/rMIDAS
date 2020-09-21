#' Instantiate Midas class
#'
#' Import Midas class into R environment, and instantiates passed parameters.
#' @keywords imputation
#' @param ... Arguments passed to the MIDAS class for instantiating network
#' @import reticulate
import_midas <- function(...) {
  midas_base <- reticulate::import_from_path("midas_base", path = system.file("python", package = "rMIDAS", mustWork = TRUE))
  midas_class <- midas_base$Midas
  attr(midas_class, "class") <- "midas"
  return(midas_class(...))
}

#' Train an imputation model using Midas
#'
#' Build and run a MIDAS neural network on the supplied missing data.
#' @keywords imputation
#' @param data A data.frame (or coercible) object, or an object of class `midas_pre` created from rMIDAS::convert()
#' @param binary_columns A vector of column names, containing binary variables. NOTE: if `data` is a `midas_pre` object, this argument will be overwritten.
#' @param softmax_columns A list of lists, each internal list corresponding to a single categorical variable and containing names of the one-hot encoded variable names. NOTE: if `data` is a `midas_pre` object, this argument will be overwritten.
#' @param training_epochs An integer, indicating the number of forward passes to conduct when running the model.
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

  # NB: savepath overwritten to R tmp directory to ensure CRAN compatibility

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
    binary_columns <- data$bin_list
    softmax_columns <- data$cat_lists
    data_in <- data$data
    transf_model = TRUE
  } else {
    data_in <- data
  }

  mod_build <- mod_inst$build_model(na_to_nan(data_in),
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
#' @keywords imputation
#' @param mid_obj Object of class `midas`, the result of running `rMIDAS::impute()`
#' @param m An integer, the number of completed datasets required
#' @param file Path to save completed datasets. If `NULL`, completed datasets are only loaded into memory.
#' @param file_root A character string, used as the root for all filenames when saving completed datasets if a `filepath` is supplied. If no file_root is provided, saved datasets will be saved as "file/midas_impute_yymmdd_hhmmss_m.csv"
#' @param unscale Boolean, indicating whether to unscale any columns that were previously minmax scaled between 0 and 1
#' @param bin_label Boolean, indicating whether to add back labels for binary columns
#' @param cat_coalesce Boolean, indicating whether to decode the one-hot encoded categorical variables
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



#' Perform overimputation diagnostic test
#'
#' `overimpute()` spikes additional missingness into the input data and reports imputation accuracy at training intervals specified by the user.
#' `overimpute()` works like `train()` -- users must specify input data, binary and categorical columns (if data is not generated via `convert()`, model parameters for the neural network, and then overimputation parameters (see below for full details).
#'
#' Accuracy is measured as the RMSE of imputed values versus actual values for continuous variables and classification error for categorical variables (i.e., the fraction of correctly predicted classes subtracted from 1).
#' Both metrics are reported in two forms:
#'   1. their summed value over all Monte Carlo samples from the estimated missing-data posterior -- "Aggregated RMSE" and "Aggregated softmax error'';
#'   2. their aggregated value divided by the number of such samples -- "Individual RMSE" and "Individual softmax error".
#'
#' In the final model, we recommend selecting the number of training epochs that minimizes the average value of these metrics --- weighted by the proportion (or substantive importance) of continuous and categorical variables --- in the overimputation exercise.  This ``early stopping'' rule reduces the risk of overtraining and thus, in effect, serves as an extra layer of regularization in the network.
#' @keywords diagnostics
#' @param spikein A numeric between 0 and 1; the proportion of observed values in the input dataset to be randomly removed.
#' @param training_epochs An integer, specifying the number of overimputation training epochs.
#' @param report_ival An integer, specifying the number of overimputation training epochs between calculations of loss. Shorter intervals provide a more granular view of model performance but slow down the overimputation process.
#' @param plot_vars Boolean, specifies whether to plot the distribution of original versus overimputed values. This takes the form of a density plot for continuous variables and a barplot for categorical variables (showing proportions of each class).
#' @param skip_plot Boolean, specifies whether to suppress the main graphical output. This may be desirable when users are conducting a series of overimputation exercises and are primarily interested in the console output. **Note**, when `skip_plot = FALSE`, users must manually close the resulting pyplot window before the code will terminate.
#' @param spike_seed,seed An integer, to initialize the pseudo-random number generators. Separate seeds can be provided for the spiked-in missingness and imputation, otherwise `spike_seed` is set to `seed` (default = 123L).
#' @inheritParams train
#' @seealso \code{\link{train}} for the main imputation function.
#' @example inst/examples/overimputation.R
overimpute <- function(# Input data
                       data,
                       binary_columns = NULL,
                       softmax_columns = NULL,

                       # Overimputation parameters
                       spikein = 0.3,
                       training_epochs,
                       report_ival = 35,
                       plot_vars = FALSE,
                       skip_plot = FALSE,
                       spike_seed = NULL,

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
                       vae_sample_var = 1.0
                       ) {

  # Not changeable currently:
  # report_samples

  # NB: plot_main not configurable to ensure compatibility between Python and R output.

  if (!(is.numeric(training_epochs))) {

     stop("`training_epochs' must be an integer, or coercible to an integer")

  }

  if (!(is.numeric(report_ival))) {

   stop("`report_ival' must be an integer, or coercible to an integer")

  }

  if (!is.numeric(spike_seed)) {

    spike_seed = seed

  }

  if (plot_vars) {
    cat("**Note**: Plotting variables is enabled.\n Overimputation will not proceed until these graphs are closed.")
  }


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

  matplotlib <- import("matplotlib", convert = TRUE)
  matplot_render <- try(matplotlib$use("TkAgg"), silent = TRUE)

  if ("try-error" %in% class(matplot_render)) {
    stop("Cannot load TkAgg, which is needed to render the overimputation plot.\n You can try installing TkAgg by running the following at the command line: `sudo apt-get install python3-tk' ")
  }

  mod_overimp <- mod_build$overimpute(spikein = spikein,
                                      training_epochs = as.integer(training_epochs),
                                      report_ival = report_ival,
                                      plot_vars = plot_vars,
                                      skip_plot = skip_plot,
                                      plot_main = FALSE,
                                      spike_seed = as.integer(spike_seed))

  return(mod_overimp)

}

