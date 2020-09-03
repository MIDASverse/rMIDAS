#' Encoding data for Midas
#'
#' `convert` pre-processes datasets to enable user-friendly interface with the main `impute` function.
#'
#' The function has two advantages over manual pre-processing:
#' 1. Utilises data.table for fast read-in and processing of large datasets
#' 2. Outputs an object that can be passed directly to `impute` without re-specifying column names etc.
#' @keywords preprocessing
#' @param data Either an object of class `data.frame`, `data.table`, or a path to a regular, delimited file.
#' @param bin_cols a vector of column names corresponding to binary variables
#' @param cat_cols a vector of column names corresponding to categorical variables
#' @param minmax_scale a logical value indicating whether to scale all numeric columns between 0 and 1, to improve model convergence
#' @return Returns custom S3 object of class 'midas_preproc' containing:
#' * \code{data} -- processed version of input data,
#' * \code{bin_list} -- vector of binary variable names
#' * \code{cat_lists} -- embedded list of one-hot encoded categorical variable names
#' * \code{minmax_params} -- list of min. and max. values for each numeric object scaled
#' @export
#' @examples
#' data = data.frame(a = sample(c("red","yellow","blue",NA),100, replace = TRUE),
#'                   b = 1:100,
#'                   c = sample(c("YES","NO",NA),100,replace = TRUE),
#'                   d = runif(100),
#'                   e = sample(c("YES","NO"), 100, replace = TRUE),
#'                   f = sample(c("male","female","trans","other",NA), 100, replace = TRUE))
#'
#' bin <- c("c","e")
#' cat <- c("a","f")
#'
#' convert(data, bin_cols = bin, cat_cols = cat)
convert <- function(data, bin_cols, cat_cols, minmax_scale = FALSE) {

  # Check data input

  if ("character" %in% class(data)) {
    data.table::fread(data)
  } else  if (!("data.table" %in% class(data))) {
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
                        function(x) c(names(data_cat_oh)[startsWith(names(data_cat_oh),paste0(x,"_"))]))
  }


  ## Check binary columns

  # List to store conversions
  bin_labs <- list()

  # For each binary column, check they are indeed binary,
  #   convert if necessary, and store corresponding labels

  for (bin_col in bin_cols) {
    b_vals <- c(unique(data_bin[,bin_col, with=FALSE]))[[1]]

    if (!(sum(!is.na(b_vals)) == 2)) {
      stop("Column '",,"' specified in bin_cols but does not have two non-missing values")

    } else if (sum(b_vals[!is.na(b_vals)] %in% c(1,2)) != 2) {

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
              minmax_params = minmax_params)

  attr(out, "class") <- "midas_preproc"

  return(out)

}





#' Replace missing values
#'
#' Helper function to convert `NA` values in a data.frame to `NaN`. This ensures the correct conversion of missing values when reticulate converts R objects to their Python equivalent. See the reticulate package documentation on type conversions for more information.
#' @keywords preprocessing
#' @export
#' @examples
#' reticulate::r_to_py(data.frame(NA))
#' # returns 1x1 data.frame containing True
#'
#' na_conv <- na_to_nan(data.frame(NA))
#' reticulate::r_to_py(na_conv)
#' # Returns 1x1 data.frame containing nan
na_to_nan <- function(df) {
  as.data.frame(apply(df,2, function(x) ifelse(is.na(x),NaN,x)))
}

#' Scales numeric vector between 0 and 1
#'
#' Helper function to scale numeric variables. Aids convergence of Midas model.
#' @keywords preprocessing
#' @param x a numeric vector or column.
#' @export
#' @examples
#' ex_num <- runif(100,1,10)
#' scaled <- col_minmax(ex_num)
col_minmax <- function(x) {
  (x-min(x, na.rm  = TRUE))/(max(x, na.rm = TRUE)-min(x, na.rm = TRUE))
}



