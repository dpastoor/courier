# startup a server following the sink pattern for zmq
init_receiving_server <- function(port = NULL) {
  context <- pbdZMQ::zmq.ctx.new()
  srvr <- pbdZMQ::zmq.socket(context, pbdZMQ::ZMQ.ST()$PULL)
  open_port <- ifelse(is.null(port), pbdZMQ::random_open_port(), port)
  pbdZMQ::zmq.bind(srvr, pbdZMQ::address("*", open_port))
  return(list(context = context,
              server = srvr,
              port = open_port)
         )
}

# cleanup the server list created from init_receiving_server
cleanup_server_list <- function(.server_list) {
  pbdZMQ::zmq.close(.server_list$server)
  pbdZMQ::zmq.ctx.destroy(.server_list$context)
  return(NULL)
}

#' run a server that follows the zmq sink receiver pattern
#' @param cb callback to call on message received
#' @param port force server to initialize on specific port
#' @details
#' after initializing the server, will print the port it has bound to,
#' so that the client sending message can be set to connect
#' @export
run_receiving_server <- function(cb = message, port = NULL) {
  srvr <- init_receiving_server(port)
  # TODO: add some color to messages printed, there should be a color package
  message(paste0("starting server on PORT: ", srvr$port))
  while(TRUE){
    msg <- pbdZMQ::zmq.recv(srvr$server)
  if (msg$buf == "__KILL__") {
    message("__KILL__ message received, shutting down server...")
    break
  }
    cb(msg$buf)
  }
  srvr <- cleanup_server_list(srvr)
  invisible()
}
