
library(pbdZMQ, quietly = TRUE)

### Initial.
context <- zmq.ctx.new()
sink <- zmq.socket(context, .pbd_env$ZMQ.ST$PUSH)
zmq.connect(sink, "tcp://localhost:5558")

### Send sink.
cat("Sending tasks to workers ...\n")

for (i in 1:100) {
zmq.send(sink, paste("completed sim", i, "from process", Sys.getpid()))
Sys.sleep(runif(1, 0, 1))
}

### Finish.
zmq.close(sink)
zmq.ctx.destroy(context)
