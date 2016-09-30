### Initial.
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
cleanup_server_list <- function(.server_list) {
  pbdZMQ::zmq.close(.pair_server_list$server)
  pbdZMQ::zmq.ctx.destroy(.pair_server_list$context)
  return(NULL)
}

run_receiving_server <- function(cb = cat) {
  srvr <- init_receiving_server()
  # TODO: add some color to messages printed, there should be a color package
  message(paste0("starting server on PORT: ", srvr$port))
  while(TRUE){
    msg <- pbdZMQ::zmq.recv(srvr$server)
  if (msg$buf == "__KILL__") {
    print("__KILL__ message received, shutting down...")
    break
  }
    print(msg)
    cb(msg$buf)
  }
  cleanup_server_list(srvr)
}

run_receiving_server()
