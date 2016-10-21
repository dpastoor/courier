library(R6)
Courier <- R6Class("courier",
     public =
       list(
         initialize = function(port) {
           print(paste("init with port", port))
           context <- pbdZMQ::zmq.ctx.new()
           sink <- pbdZMQ::zmq.socket(context, pbdZMQ::ZMQ.ST()$PUSH)
           pbdZMQ::zmq.connect(sink,
                               pbdZMQ::address("localhost",
                                               port))
           private$port <<- port
           private$context <<- context
           private$client <<- sink
           print(paste("successfully init with port", port))
         },
         finalize = function() {
           print("Finalizer has been called!")
           pbdZMQ::zmq.close(private$client)
           pbdZMQ::zmq.ctx.destroy(private$context)
           print("done cleaning up!")
         },
         send_msg = function(msg) {
          print("sending message:")
          print(msg)
          pbdZMQ::zmq.send(private$client, msg)
          invisible()
         }
       ),
     private =
       list(
         port = NULL,
         client = NULL,
         context = NULL
       )
)
msgr <- Courier$new(5555)
msgr$send_msg("hello")
rm(msgr)
gc()
