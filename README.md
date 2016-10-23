courier
=========

The courier package is designed to provide a method of quick unstructured logging to a separate server instance (language agnostic). This is especially useful in two contexts

1) You want to keep a record of what is going on in your main process beyond printing to the console

and more usefully

2) You are working in a parallelizable context and want to send messages
out from a worker thread. As messages do not bubble up

The entire construction/teardown of the machinery takes less than 3 ms, making it very low overhead

## Example usage for parallelizing simulations with future


#### Start a separate R thread either in your shell via `R` or open a separate Rstudio instance
```r
courier::run_receiving_server()
## outputs in this instance found open port to run on 50813
```

#### In your main process
```r
library(future)
library(courier)
library(purrr)
library(dplyr)

my_sim <- function(rep) {
  Sys.sleep(5) ## emulate process that takes 5 seconds to complete
  courier_msg(paste("completed rep", rep, "on process", Sys.getpid()))
  return(runif(1, 0, 10))
}

## need to inject access to the courier_msg function as well
## as proper setup and teardown of connection of the server
PORT <- 50183 # given from server
sim_w_message <- decorate_simulation(my_sim, PORT)

## run each future on the main thread
sim_sequentially <- function() {
  plan(transparent)
  sims <- lapply(1:8, function(x) {
    val <- future({
      message("you'll see this message about starting the sim")
      sim_w_message(x)
    })
  })
  map_dbl(sims, value)
}

sim_parallel <- function() {
  plan(multiprocess)
  sims <- lapply(1:8, function(x) {
    val <- future({
      message("you'll never see this message about starting the sim")
      sim_w_message(x)
    })
  })
  map_dbl(sims, value)
}
```

```r
sim_sequentially()
## outputs
# completed rep 1 on process 55225
# completed rep 2 on process 55225
# completed rep 3 on process 55225
# completed rep 4 on process 55225
# completed rep 5 on process 55225
# completed rep 6 on process 55225
# completed rep 7 on process 55225
# completed rep 8 on process 55225

sim_parallel()
## outputs
# completed rep 2 on process 57442
# completed rep 1 on process 57441
# completed rep 3 on process 57443
# completed rep 4 on process 57444
# completed rep 5 on process 57445
# completed rep 6 on process 57446
# completed rep 7 on process 57447
# completed rep 8 on process 57457
```

Notice in sim_parallel

A representative benchmark on a 4 core macbook pro

```r
mb_res <- microbenchmark::microbenchmark(
  sim_sequentially(),
  sim_parallel(),
  times = 5L)
mb_res
```


```r
unix_to_seconds <- function(x) return(round(x/1000000000,2))
mb_res %>% 
as.data.frame() %>% 
group_by(expr) %>% 
summarize_at(vars(-expr), funs(min, median, max)) %>%
mutate_at(vars(-expr), funs(unix_to_seconds)) %>% 
knitr::kable()
```

Run times, in seconds. 40 seconds of work via 8 reps x 5 seconds per rep sleeping, with parallelization across 4 cores for parallel sim

|expr               |   min| median|   max|
|:------------------|-----:|------:|-----:|
|sim_sequentially() | 40.06|  40.06| 40.07|
|sim_parallel()     | 10.96|  10.97| 13.11|

### TODO (in somewhat order of priority)

* [ ] Implement JSON send/receive servers for structured logging 
* [ ] Log messages to file
* [ ] Full test coverage
* [ ] GUI for server in either Shiny or Go

