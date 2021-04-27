#' Pre-process data for Midas imputation
#'
#' `convert` pre-processes datasets to enable user-friendly interface with the main `train()` function.
#'
#' The function has two advantages over manual pre-processing:
#' 1. Utilises data.table for fast read-in and processing of large datasets
#' 2. Outputs an object that can be passed directly to `train()` without re-specifying column names etc.
#' @keywords preprocessing
#' @param data Either an object of class `data.frame`, `data.table`, or a path to a regular, delimited file
#' @param bin_cols,cat_cols A vector, column names corresponding to binary and categorical variables respectively
#' @param minmax_scale Boolean, indicating whether to scale all numeric columns between 0 and 1, to improve model convergence
#' @return Returns custom S3 object of class `midas_preproc' containing:
#' * \code{data} -- processed version of input data,
#' * \code{bin_list} -- vector of binary variable names
#' * \code{cat_lists} -- embedded list of one-hot encoded categorical variable names
#' * \code{minmax_params} -- list of min. and max. values for each numeric object scaled
#' @import data.table
#' @import mltools
#' @export
#' @return List containing converted data, categorical and binary labels to be imported into the imputation model, and scaling parameters for post-imputation transformations.
#' @examples
#' data = data.frame(a = sample(c("red","yellow","blue",NA),100, replace = TRUE),
#'                   b = 1:100,
#'                   c = sample(c("YES","NO",NA),100,replace = TRUE),
#'                   d = runif(100),
#'                   e = sample(c("YES","NO"), 100, replace = TRUE),
#'                   f = sample(c("male","female","trans","other",NA), 100, replace = TRUE),
#'                   stringsAsFactors = FALSE)
#'
#' bin <- c("c","e")
#' cat <- c("a","f")
#'
#' convert(data, bin_cols = bin, cat_cols = cat)
convert <- function(data, bin_cols = NULL, cat_cols = NULL, minmax_scale = FALSE) {

  # Check data input

  if (inherits(data,"character")) {
    data.table::fread(data)
  } else  if (!inherits(data,"data.table")) {
    data.table::setDT(data)
  }

  # Check all column names are present
  all_names <- c(bin_cols, cat_cols)

  if (sum(all_names %in% names(data)) != length(all_names)) {

    name_errs <- all_names[!(all_names %in% names(data))]

    stop("The following column names could not be found in the data: ",
         paste0("'",name_errs,sep="' "))
  }

  # Check no overlap between bin and cat
  if (length(intersect(bin_cols, cat_cols)) > 0) {
    stop("At least one variable name is duplicated in the binary and categorical arguments.")
  }

  # Separate the data by class
  data_bin <- data[,bin_cols, with = FALSE]
  data_cat <- data[,cat_cols, with = FALSE]
  data_num <- data[,setdiff(names(data),all_names), with = FALSE]

  num_cols <- names(data_num)

  # One-hot encode categorical
  cat_lists <- NULL
  data_cat_oh <- NULL
  if (ncol(data_cat) > 0) {
    data_cat[,(cat_cols):=lapply(.SD, as.factor),.SDcols=cat_cols]
    data_cat_oh <- mltools::one_hot(data_cat, cols = names(data_cat))

    cat_lists <- lapply(cat_cols,
                        function(x) {

                          tmp_names <- names(data_cat_oh)
                          # Locate whether other variables share same root e.g. c("var1", "var1_other")
                          if (sum(grepl(x, cat_cols)) > 1) {

                            var_matches <- cat_cols[grep(x, cat_cols)]

                            # Get vector of variables to remove from matching
                            del_vars <- var_matches[!(var_matches == x)]

                            # Loop through and delete
                            for (del_var in del_vars) {
                              tmp_names <- tmp_names[!grepl(del_var, tmp_names)]
                            }
                          }

                          # Now find one-hot encoded names
                          c(tmp_names[startsWith(tmp_names,paste0(x,"_"))])
                        })

  }


  ## Check binary columns

  # List to store conversions
  bin_labs <- list()

  # For each binary column, check they are indeed binary,
  #   convert if necessary, and store corresponding labels

  for (bin_col in bin_cols) {
    b_vals <- c(unique(data_bin[,bin_col, with=FALSE]))[[1]]

    if (!(sum(!is.na(b_vals)) == 2)) {
      stop("Column '",bin_col,"' does not have two non-missing values")

    } else if (sum(b_vals[!is.na(b_vals)] %in% c(1,0)) != 2) {

      data_bin[,bin_col] <- ifelse(data_bin[,bin_col, with = FALSE] == b_vals[!is.na(b_vals)][1],
                                   1L,0L)
    }

    bin_labs[[bin_col]] <- b_vals[!is.na(b_vals)]
  }

  # Min-max scale
  minmax_params <- NULL
  if (minmax_scale) {

    minmax_params <- lapply(data_num, function(x) {return(list(min = min(x, na.rm = TRUE),
                                                 max = max(x, na.rm = TRUE)))})

    data_num[,(num_cols):=lapply(.SD, col_minmax),.SDcols=num_cols]
  }

  data_conv <- cbind(data_num, data_bin, data_cat_oh)

  type_check <- data_conv[,lapply(.SD, is.character)]

  if (sum(type_check == TRUE) > 0) {
    type_vars <- names(type_check)[type_check == TRUE]
    warning("The following columns have not been converted to a numeric type: ",
            paste0("'",type_vars, sep ="' "))
  }

  out <- list(data = data_conv,
              bin_list = bin_labs,
              cat_lists = cat_lists,
              cat_names = names(data_cat),
              minmax_params = minmax_params)

  attr(out, "class") <- "midas_pre"

  return(out)

}





#' Replace NA missing values with NaN
#'
#' Helper function to convert `NA` values in a data.frame to `NaN`. This ensures the correct conversion of missing values when reticulate converts R objects to their Python equivalent. See the reticulate package documentation on type conversions for more information.
#' @keywords preprocessing
#' @param df Data frame, or object coercible to one.
#' @export
#' @return Data frame with `NA` values replaced with `NaN` values.
#' @examples
#' na_to_nan(data.frame(a = c(1,NA,0,0,NA,NA)))
na_to_nan <- function(df) {
  as.data.frame(apply(df,2, function(x) ifelse(is.na(x),NaN,x)))
}

#' Scale numeric vector between 0 and 1
#'
#' Helper function to scale numeric variables. Aids convergence of Midas model.
#' @keywords preprocessing
#' @param x A numeric vector or column.
#' @export
#' @return Vector scaled between 0 and 1
#' @examples
#' ex_num <- runif(100,1,10)
#' scaled <- col_minmax(ex_num)
col_minmax <- function(x) {
  (x-min(x, na.rm  = TRUE))/(max(x, na.rm = TRUE)-min(x, na.rm = TRUE))
}


# Run imputation models  -- essentially a wrapper for mice or whatever we use in the

#' Reverse minmax scaling of numeric vector
#'
#' Helper function to reverse minmax scaling applied in the pre-processing step.
#' @keywords postprocessing
#' @param s A numeric vector or column, scaled between 0 and 1.
#' @param s_min A numeric value, the minimum of the unscaled vector
#' @param s_max A numeric value, the maximum of the unscaled vector
#' @export
#' @return Vector re-scaled using original parameters `s_min` and `s_max`
#' @examples
#' ex_num <- runif(100,1,10)
#' scaled <- col_minmax(ex_num)
#' undo_scale <- undo_minmax(scaled, s_min = min(ex_num), s_max = max(ex_num))
#'
#' # Prove two are identical
#' all.equal(ex_num, undo_scale)
undo_minmax <- function(s, s_min, s_max) {

  x <- s*(s_max-s_min) + s_min

}

#' Reverse numeric conversion of binary vector
#'
#' Helper function to re-apply binary variable labels post-imputation.
#' @keywords postprocessing
#' @param x A numeric vector or column, scaled between 0 and 1
#' @param one A character string, the label associated with binary value 1
#' @param zero A character string, the label associated with binary value 0
#' @param fast Boolean indicating whether to return binary value 1 if predicted probability >= 0.5  (TRUE), or take random draw using predicted probability as weighting.
#' @export
#' @return Vector of character strings corresponding to binary values
#' @examples
#' ex_bin <- c(1,0,0,1,1,0,0,1,0)
#' cat <- "cat"
#' dog <- "dog"
#'
#' add_bin_labels(x = ex_bin, one = cat, zero = dog)
add_bin_labels <- function(x, one, zero, fast = TRUE) {

  if (fast) {
    x_out <- factor(ifelse(x >= 0.5, one, ifelse(x<0.5,zero,NA)),
                    levels = c(zero, one))
  } else {
    bin_draw <- stats::rbinom(length(x),1,x)
    x_out <- factor(ifelse(bin_draw == 1, one, ifelse(bin_draw == 0, zero, NA)),
                    levels = c(zero, one))
  }

  return(x_out)

}

#' Coalesce one-hot encoding back to a single variable
#'
#' Helper function to reverse one-hot encoding post-imputation.
#' @keywords postprocessing
#' @param X A data.frame, data.table or matrix, for a single variable
#' @param var_name A character string, with the original variable label
#' @param fast Boolean, indicating whether to choose category with highest predicted probability (TRUE), or use predicted probabilities as weights in draw from random distribution
#' @import data.table
#' @return A vector of length equal to `nrow(X)`, containing categorical labels corresponding to the columns of `X`
coalesce_one_hot <- function(X, var_name, fast = TRUE) {

  X_copy <- data.table::copy(X)

  X_names <- names(X_copy)

  set.seed(89)
  if (fast) {
    X_max <- apply(X_copy, 1, which.max)
    X_max_cat <- sub(paste0(var_name,"_"),"",X_names)[X_max]
  } else {
    X_max <- apply(X_copy, 1, function (r) sample(X_names, 1, prob = r))
    X_max_cat <- sub(paste0(var_name,"_"),"",X_max)
  }

  return(X_max_cat)

}


#' Apply MAR missingness to data
#'
#' Helper function to re-apply binary variable labels post-imputation.
#' @keywords preprocessing
#' @param X A data.frame or similar
#' @param prop Numeric between 0 and 1; the proportion of observations set to missing
#' @param cols A vector of column names to be corrupted; if NULL, all columns are used
#' @export
#' @return Data with missing values
#' @examples
#' whole_data <- data.frame(a = rnorm(1000),
#'                         b = rnorm(1000))
#'
#' missing_data <- add_missingness(whole_data, 0.1)
add_missingness <- function(X, prop, cols = NULL) {


  if (is.null(cols)) {
    cols <- names(X)
  }

  for (column in cols) {

    # Generate an indicator variable with 10% probability of assigning missingness
    r <- sample(c(FALSE,TRUE),
                length(X[[column]]),
                replace = TRUE, prob = c(1-prop,prop))

    # Corrupt data based on missingness indicator
    X[[column]] <- ifelse(r, NA, X[[column]])
  }

  return(X)

}


