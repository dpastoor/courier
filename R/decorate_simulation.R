#' add send_message function to a user-defined function
#' @param .f function
#' @param .port port send_message will communication on
#' @details
#' decorate_simulation will give the ability of the decorated function
#' to use a function with a signature send_message(x) where
#' x is a string message. This message will be send via zmq
#' to the receiving server. Client connection and teardown
#' happen transparently
#' @export
#' @examples \dontrun{
#'  PORT <- 5678 # number would be taken from run_receiving_server()
#'  my_sim <- decorate_simulation(function(rep) {
#'  send_message(paste("on rep", rep))
#'  # emulate 1 second of simulation 'work'
#'  Sys.sleep(1)
#'  return(runif(1, 0, 100))
#'  }, PORT)
#'
#'  lapply(1:10, my_sim)
#' }
decorate_simulation <- function(.f, .port) {
    .e <- new.env()
    assign("send_message",
           function(x) {
              .client <- init_sink_client(.port)
              send_msg <- send_message_factory(.client)
              send_msg(x)
              cleanup_zmq_list(.client)
           },
           envir = .e,
           inherits = T)
  scoped_func <- function(...) {
    .client <- courier::init_sink_client(.port)
    res <- .f(...)
    courier::cleanup_zmq_list(.client)
    return(res)
  }
  environment(scoped_func) <- .e
  return(scoped_func)
}
