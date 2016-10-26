#' Server to receive messages
#' @importFrom R6 R6Class
#' @name Receiver
#' @examples
#' \dontrun{
#' srvr <- Receiver$new() # will pick random open port
#' srvr$listen()
#' }
NULL

#' @export
Receiver <- R6Class("Receiver",
     public =
       list(
         verbose = NULL,
         log = NULL,
         cb = NULL,
         initialize = function(port = NULL,
                               cb = print,
                               verbose = TRUE,
                               log = FALSE
                               ) {
           self$verbose <<- verbose
           self$log <<- log
           self$cb <<- cb
           open_port <- ifelse(is.null(port), pbdZMQ::random_open_port(), port)

           context <- pbdZMQ::zmq.ctx.new()
           srvr <- pbdZMQ::zmq.socket(context, pbdZMQ::ZMQ.ST()$PULL)
           pbdZMQ::zmq.bind(srvr, pbdZMQ::address("*", open_port))

           private$port <<- open_port
           private$context <<- context
           private$server <<- srvr

           if (self$verbose) {
              message(paste("set to listen on: ", open_port))
           }
         },
          listen = function() {
            message(paste("listening on: ", private$port))
            tryCatch(
              while(TRUE){
                msg <- pbdZMQ::zmq.recv(private$server)
                if (msg$buf == "__KILL__") {
                  message("__KILL__ message received, shutting down server...")
                  break
                }
                self$cb(msg$buf)
              },
            interrupt = function(i) {
              print("shutting down!")
            })
            invisible()
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
