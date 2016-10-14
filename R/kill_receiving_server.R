#' send a kill message to a listening receiving server
#' @param .port port server is listening on
#' @export
kill_receiving_server <- function(.port) {
    .client <- init_sink_client(.port)
    send_msg <- send_message_factory(.client)
    send_msg("__KILL__")
    cleanup_zmq_list(.client)
    message("kill request sent")
    return(TRUE)
}
