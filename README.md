Experimenting with Ruby's Net::HTTP and network failure.

# Intro

I've played around with injecting Toxiproxy, tc latency and iptable drop
failures into Ruby's Net::HTTP requests. As expected, the result is that
Toxiproxy behaves quite differently than tc and iptables because it is a layer
4 proxy and the other two operate at a lower layer.

# Summary of Results

- Latency or dropping via iptables / tc causes a Net::OpenTimeout because the
  handshake packets never arrive at the destination.
- Toxiproxy down causes an Errno::ECONNREFUSED because the the handshake
  packets reach the destination and the OS rejects the connection because there
  is no socket listening on that port.
- Toxiproxy latency causes a Net::ReadTimeout because the packets reach the
  destination without latency but the HTTP body has latency applied and
  therefore never reaches the destination for a response.
- Toxiproxy down will immediately close any open TCP connections. This will
  cause a keep alive connection to reset.
- Toxiproxy latency is safe to turn on and off during a connection without
  damaging the connection.
- Do not trust Ruby's http.alive? / open methods because they seem to always
  return true once an HTTP session is established. Even after it is closed via
  Toxiproxy down.

# Results

## Get with no failures.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/get.rb`

#### Result

200

## Get with iptables drop.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/with_drop.rb`
- `bundle exec ruby bin/get.rb`

#### Result

Net::OpenTimeout

## Get with tc latency.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/with_latency.rb`
- `bundle exec ruby bin/get.rb`

#### Result

Net::OpenTimeout

## Get with toxiproxy and no failures.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/get.rb`

#### Result

200

## Get with toxiproxy and disabled proxy.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/with_toxi_disabled.rb`
- `bundle exec ruby bin/get.rb`

#### Result

Errno::ECONNREFUSED

## Get with toxiproxy and latency toxic.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/with_toxi_latency.rb`
- `bundle exec ruby bin/get.rb`

#### Result

Net::ReadTimeout

## Get keep alive with no failures.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, 200]

## Get keep alive with iptables drop in the middle and not released.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/with_drop.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, Net::OpenTimeout]

## Get keep alive with iptables drop in the middle and released before second request.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/with_drop.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, 200]

## Get keep alive with tc latency in the middle and not released.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/with_latency.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, Net::OpenTimeout]

## Get keep alive with tc latency in the middle and released before second request.

- `bundle exec ruby bin/server.rb 1234`
- `bundle exec ruby bin/with_latency.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, 200]

## Get keep alive with toxiproxy and no failure.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, 200] On the same TCP connection.

## Get keep alive with toxiproxy proxy disabled in the middle and not released.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/with_toxi_disabled.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, Errno::ECONNREFUSED]

## Get keep alive with toxiproxy proxy disabled in the middle and released before second request.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/with_toxi_disabled.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, 200] On diffrent TCP connections.

## Get keep alive with toxiproxy latency in the middle and not released.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/with_toxi_latency.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, Net::ReadTimeout]

## Get keep alive with toxiproxy latency in the middle and released before second request.

- `bundle exec ruby bin/server.rb 1235`
- `toxiproxy-server`
- `bundle exec ruby bin/populate.rb`
- `bundle exec ruby bin/with_toxi_latency.rb`
- `bundle exec ruby bin/get_keep_alive.rb`

#### Result

[200, 200] On the same TCP connection.
