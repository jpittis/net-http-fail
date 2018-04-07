require 'net/http'

def get_keep_alive(open_timeout: 5, read_timeout: 5, keep_alive_timeout: 30)
  http = Net::HTTP.new('127.0.0.1', 1234)
  http.open_timeout = open_timeout
  http.read_timeout = read_timeout
  http.keep_alive_timeout = keep_alive_timeout
  http.set_debug_output $stderr
  responses = []
  http = http.start
  puts http.inspect
  responses << http.request_get('/').code
  puts 'newline for second get request'
  gets
  puts http.inspect
  responses << http.request_get('/').code
rescue => e
  responses << e.class.name
ensure
  puts http.inspect
  responses
end

p get_keep_alive

