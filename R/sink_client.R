#' set up client to interact with server
#' @param port port the server is listening on
#' @details
#' the flow for use should be, in a separate process to setup
#' the server via run_receiving_server() and to note the
#' port set to pass to init_sink_client()
#' @export
init_sink_client <- function(port) {
  context <- pbdZMQ::zmq.ctx.new()
  sink <- pbdZMQ::zmq.socket(context, pbdZMQ::ZMQ.ST()$PUSH)
  pbdZMQ::zmq.connect(sink, pbdZMQ::address("localhost", port))
  return(list(client = sink, context = context, port = port))
}

#' factory function to create fun to send messages to sink server
#' @param .sink_client_list the list output from init_sink_client
#' @examples
#' # port would be set from server startup
#' client <- init_sink_client(5556)
#' send_msg <- sink_send_factory(client)
#' send_msg("a message")
#' @export
sink_send_factory <- function(.sink_client_list) {
  return(function(msg) {
    pbdZMQ::zmq.send(.sink_client_list$client, msg)
    invisible()
  })
}
client <- init_sink_client(61726)
send_msg <- sink_send_factory(client)
send_msg("a message")
send_msg("__KILL__")
### Send sink.
# cat("Sending tasks to workers ...\n")
#
# for (i in 1:10) {
# zmq.send(sink, paste("completed sim", i, "from process", Sys.getpid()))
# Sys.sleep(runif(1, 0, 1))
# }
# zmq.send(sink, "__KILL__")
# ### Finish.
# zmq.close(sink)
# zmq.ctx.destroy(context)
