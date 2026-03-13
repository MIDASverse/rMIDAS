Sys.setenv(
  OMP_NUM_THREADS = "1",
  OMP_THREAD_LIMIT = "1",
  OPENBLAS_NUM_THREADS = "1",
  MKL_NUM_THREADS = "1",
  BLIS_NUM_THREADS = "1",
  VECLIB_MAXIMUM_THREADS = "1",
  NUMEXPR_NUM_THREADS = "1",
  TF_NUM_INTRAOP_THREADS = "1",
  TF_NUM_INTEROP_THREADS = "1"
)

if (requireNamespace("data.table", quietly = TRUE)) {
  data.table::setDTthreads(1L)
}

library(testthat)
library(rMIDAS)

test_check("rMIDAS")
