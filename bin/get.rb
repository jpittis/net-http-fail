require 'net/http'

def get(open_timeout: 5, read_timeout: 5)
  http = Net::HTTP.new('127.0.0.1', 1234)
  http.open_timeout = open_timeout
  http.read_timeout = read_timeout
  http.get('/').code
rescue => e
  e.class.name
end

puts get
