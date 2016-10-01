
library(pbdZMQ, quietly = TRUE)

### Initial.
init_sink_client <- function(port) {
  context <- zmq.ctx.new()
  sink <- zmq.socket(context, pbdZMQ::ZMQ.ST()$PUSH)
  pbdZMQ::zmq.connect(sink, pbdZMQ::address("*", port))
  return(list(client = sink, context = context, port = port))
}

sink_send_factory <- function(.sink_client_list) {
  return(function(msg) {
    pbdZMQ::zmq.send(.sink_client_list$client, msg)
    return(msg)
  })
}
### Send sink.
cat("Sending tasks to workers ...\n")

for (i in 1:10) {
zmq.send(sink, paste("completed sim", i, "from process", Sys.getpid()))
Sys.sleep(runif(1, 0, 1))
}
zmq.send(sink, "__KILL__")
### Finish.
zmq.close(sink)
zmq.ctx.destroy(context)
