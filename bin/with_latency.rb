delay = '6000'
begin
  # This will cause latency 2 times the delay.
  `tc qdisc add dev lo root netem delay #{delay}ms`
  puts 'newline to cleanup'
  gets
ensure
  `tc qdisc del dev lo root netem`
end
