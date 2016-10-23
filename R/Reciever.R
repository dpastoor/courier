Receiver <- R6::R6Class("Receiver",
     public =
       list(
         verbose = NULL,
         log = NULL,
         initialize = function(port = NULL,
                               verbose = TRUE,
                               log = FALSE
                               ) {
           self$verbose <<- verbose
           self$log <<- log

           open_port <- ifelse(is.null(port), pbdZMQ::random_open_port(), port)

           context <- pbdZMQ::zmq.ctx.new()
           srvr <- pbdZMQ::zmq.socket(context, pbdZMQ::ZMQ.ST()$PULL)
           pbdZMQ::zmq.bind(srvr, pbdZMQ::address("*", open_port))

           private$port <<- open_port
           private$context <<- context
           private$server <<- srvr

           if (self$verbose) {
              message(paste("listening on: ", open_port))
           }
         },
         finalize = function() {
           pbdZMQ::zmq.close(private$server)
           pbdZMQ::zmq.ctx.destroy(private$context)
           if (self$verbose) {
             message(paste0("Courier server successfully shutdown"))
           }
         }
       ),
     private =
       list(
         port = NULL,
         server = NULL,
         context = NULL
       )
)
