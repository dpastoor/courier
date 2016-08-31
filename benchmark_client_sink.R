
library(pbdZMQ, quietly = TRUE)

### Initial.
sim_ind <- function() {
  context <- zmq.ctx.new()
  sink <- zmq.socket(context, .pbd_env$ZMQ.ST$PUSH)
  zmq.connect(sink, "tcp://localhost:5558")
  zmq.send(sink, paste("completed sim", runif(1, 1, 10), "from process", Sys.getpid()))
  zmq.close(sink)
  zmq.ctx.destroy(context)
}

library(microbenchmark)
microbenchmark(
 sim_ind(),
 times = 20L
)
