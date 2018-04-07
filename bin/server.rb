require 'rack'

class SuccessServer
  attr_reader :port

  def initialize(port)
    @port = port
  end

  def call(_env)
    ['200', { 'Content-Type' => 'text/html' }, ['success']]
  end

  def run
    Rack::Handler::WEBrick.run(self,
                               Port: port,
                               AccessLog: [],
                               Logger: WEBrick::Log.new('/dev/null'))
  end
end

SuccessServer.new(ARGV[0]).run
