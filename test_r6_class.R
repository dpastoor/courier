library(R6)
Courier <- R6Class("courier",
     public =
       list(
         initialize = function(port) {
           print(paste("init with port", port))
           private$port <<- port
         },
         finalize = function() {
           print("Finalizer has been called!")
         },
         send_msg = function(x) {
           print("sending message:")
          print(x)
         }
       ),
     private =
       list(
         port = NULL
       )
)
new_courier <- Courier$new(12)
new_courier$send_msg("hello")
rm(new_courier)
gc()
