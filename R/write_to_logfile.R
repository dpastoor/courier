#' write a string of text to a log file
#' @param x string to write to file
#' @param .file file to write to
write_to_logfile <- function(x, .file) {
  if (!as.character(x) && length(x) == 1) {
    warning("cannot write anything but single character string to file")
    return(invisible())
  }
  .file <- file(.file, open = "a")
  on.exit(close(.file))
  writeLines(x, .file)
  invisible()
}
