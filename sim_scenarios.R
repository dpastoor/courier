library(dplyr)
library(future)
library(courier)
library(purrr)
send_message <- function(x) {
  print(x)
  return(x)
}
my_sim <- function(rep) {
  Sys.sleep(1)
  courier_msg(paste("on rep", rep))
  return(runif(1, 0, 10))
}

sim_w_message <- decorate_simulation(my_sim, 50183)

sim_sequentially <- function() {
  plan(eager)
  sims <- lapply(1:10, function(x) {
    val <- future({
      sim_w_message(x)
    })
  })
  map_dbl(sims, value)
}

sim_parallel <- function() {
  plan(multiprocess)
  sims <- lapply(1:10, function(x) {
    val <- future({
      sim_w_message(x)
    })
  })
  map_dbl(sims, value)
}

mb_res <- microbenchmark::microbenchmark(
  sim_sequentially(),
  sim_parallel(),
  times = 5L)
