require 'toxiproxy'

# Expects server to listen on port 1235.
Toxiproxy.populate([{
  name: "server",
  listen: "localhost:1234",
  upstream: "localhost:1235",
}])
