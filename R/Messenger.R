#' Send messages to a Reciever
#' @importFrom R6 R6Class
#' @name Messenger
#' @importFrom jsonlite toJSON
#' @examples
#' \dontrun{
#' msgr <- Messenger$new(12345) # provided from listening Reciever
#' msgr$send_msg("hello")
#' }
NULL

#' @export
Messenger <- R6Class("Messenger",
     public =
       list(
         verbose = NULL,
         block = NULL,
         initialize = function(port,
                               verbose = FALSE,
                               block = FALSE,
                               host = "localhost") {
           self$verbose <<- verbose
           self$block <<- block
           context <- pbdZMQ::zmq.ctx.new()
           sink <- pbdZMQ::zmq.socket(context, pbdZMQ::ZMQ.ST()$PUSH)
           pbdZMQ::zmq.connect(sink,
                               pbdZMQ::address(host,
                                               port))
           private$port <<- port
           private$context <<- context
           private$client <<- sink
           if (self$verbose) {
              message(paste("successfully initialized on: ", port))
           }
         },
         finalize = function() {
           if (self$verbose) {
             message(paste0("Messenger instance about to be shutdown"))
           }
           pbdZMQ::zmq.close(private$client)
           pbdZMQ::zmq.ctx.destroy(private$context)
           if (self$verbose) {
             message(paste0("Messenger instance successfully shutdown"))
           }

         },
         # msg should be a single string
         send_msg = function(msg) {
           if (!is.character(msg) && length(msg) == 1) {
             stop("msg must be a single character string,
                  you can always concatenate multipart messages
                  with paste0")
           }
           if(self$block) {
              pbdZMQ::zmq.send(private$client, msg)
           } else {
              pbdZMQ::zmq.send(private$client,
                               msg,
                               flags = pbdZMQ::ZMQ.SR()$NOBLOCK)
           }
          invisible()
         },
         log = function(msg, level = 1, type = "INFO") {
           if (!is.character(msg) && length(msg) == 1) {
             stop("msg must be a single character string,
                  you can always concatenate multipart messages
                  with paste0")
           }
           msg <- toJSON(list(
             "message" = msg,
             "pid" = Sys.getpid(),
             "time" = Sys.time(),
             "type" = type,
             "level" = level
             ), auto_unbox = TRUE)
           if(self$block) {
              pbdZMQ::zmq.send(private$client, msg)
           } else {
              pbdZMQ::zmq.send(private$client,
                               msg,
                               flags = pbdZMQ::ZMQ.SR()$NOBLOCK)
           }
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
#msgr <- Messenger$new(5555, TRUE, block = FALSE)
#msgr$send_msg(paste0("uid: ", round(runif(1, 0, 10), 3)))
#msgr$send_kill_msg()
#msgr$send_msg(paste0("uid: ", round(runif(1, 0, 10), 3)))
#rm(msgr)
#gc()
#
# msgr <- Messenger$new(5556, TRUE)
# msgr$send_msg(paste0("uid: ", round(runif(1, 0, 10), 3)))
# msgr$log(paste0("uid: ", round(runif(1, 0, 10), 3)))
# msgr$send_kill_msg()
# rm(msgr)
# gc()
## will get stuck until the server is started again to drain
## the messages waiting to be sent
#
