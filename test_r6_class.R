Courier <- R6::R6Class("courier",
     public =
       list(
         verbose = FALSE,
         initialize = function(port, verbose = FALSE) {
           print(paste("init with port", port))
           context <- pbdZMQ::zmq.ctx.new()
           sink <- pbdZMQ::zmq.socket(context, pbdZMQ::ZMQ.ST()$PUSH)
           pbdZMQ::zmq.connect(sink,
                               pbdZMQ::address("localhost",
                                               port))
           private$port <<- port
           private$context <<- context
           private$client <<- sink
           self$verbose <<- verbose
           if (self$verbose) {
              message(paste("successfully initialized on: ", port))
           }
         },
         finalize = function() {
           pbdZMQ::zmq.close(private$client)
           pbdZMQ::zmq.ctx.destroy(private$context)
           if (self$verbose) {
             message(paste0("Courier instance successfully shutdown"))
           }

         },
         # msg should be a single string
         send_msg = function(msg) {
           if (!is.character(msg) && length(msg) == 1) {
             stop("msg must be a single character string,
                  you can always concatenate multipart messages
                  with paste0")
           }
          pbdZMQ::zmq.send(private$client, msg)
          invisible()
         },
         send_kill_msg = function(){
          pbdZMQ::zmq.send(private$client, "__KILL__")
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
msgr <- Courier$new(5555, TRUE)
msgr$send_msg(paste0("uid: ", round(runif(1, 0, 10), 3)))
#msgr$send_kill_msg()
rm(msgr)
gc()
