library(dplyr)
library(future)
library(courier)
library(purrr)
my_sim <- function(rep) {
  Sys.sleep(4)
  msgr <- Courier$new(5555)
  msgr$send_msg(paste("on rep", rep, "process", Sys.getpid()))
  return(runif(1, 0, 10))
}


sim_sequentially <- function() {
  plan(eager)
  sims <- lapply(1:8, function(x) {
    val <- future({
      my_sim(x)
    })
  })
  map_dbl(sims, value)
}

sim_parallel <- function() {
  plan(multiprocess)
  sims <- lapply(1:8, function(x) {
    val <- future({
      my_sim(x)
    })
  })
  map_dbl(sims, value)
}

mb_res <- microbenchmark::microbenchmark(
  sim_sequentially(),
  sim_parallel(),
  times = 5L)
