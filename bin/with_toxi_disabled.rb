require 'toxiproxy'

Toxiproxy['server'].down do
  puts 'newline to cleanup'
  gets
end
