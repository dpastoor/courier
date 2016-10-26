#' send a kill message to a listening Receiver server
#' @param .port port server is listening on
#' @export
kill_receiver_on_port <- function(.port) {
    msgr <- Messenger$new(.port)
    msgr$send_kill_msg()
    return(TRUE)
}
