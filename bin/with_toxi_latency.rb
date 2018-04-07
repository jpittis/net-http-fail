require 'toxiproxy'

delay = 6000
Toxiproxy['server'].upstream(:latency, latency: delay).downstream(:latency, latency: delay).apply do
  puts 'newline to cleanup'
  gets
end
