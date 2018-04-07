port = '1234'
begin
  `iptables -I OUTPUT -p tcp -o lo --dport #{port} -j DROP`
  puts 'newline to cleanup'
  gets
ensure
  `iptables -D OUTPUT -p tcp -o lo --dport #{port} -j DROP`
end
