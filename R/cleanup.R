#' cleanup the list object created from init functions
#' @param .zmq_list list object containing zmq context, and server|client instance
#' @details
#' when cleaning up the created object, the null output of cleanup_zmq_list
#' should be used to overwrite the existing object so the stored pointers
#' are not accessed in the future
#' @examples \dontrun{
#' client <- init_sink_client(1111)
#' client <- cleanup_zmq_list(client)
#' }
#' @export
cleanup_zmq_list <- function(.zmq_list) {
  if (!is.null(.zmq_list$server)) {
    pbdZMQ::zmq.close(.zmq_list$server)
  }
  if (!is.null(.zmq_list$client)) {
    pbdZMQ::zmq.close(.zmq_list$client)
  }
  pbdZMQ::zmq.ctx.destroy(.zmq_list$context)
  return(NULL)
}
