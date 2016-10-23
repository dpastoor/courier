tryCatch(
  Sys.sleep(10),
  interrupt = function(i) {
    print("shutting down!")
  }
)
