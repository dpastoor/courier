library(pbdZMQ, quietly = TRUE)

### Initial.
context <- zmq.ctx.new()
receiver <- zmq.socket(context, .pbd_env$ZMQ.ST$PULL)
zmq.bind(receiver, "tcp://*:5558")

### Wait for start of batch.
print("listening on socket 5558 for messages")
while (TRUE) {
  string <- zmq.recv(receiver)
  if (string$buf == "__KILL__") {
    print("__KILL__ message received, shutting down...")
    break
  }
  print(string$buf)
}

### Finish.
zmq.close(receiver)
zmq.ctx.destroy(context)
