require 'rubygems'
require 'eventmachine'

module EchoServer  
  def receive_data(data) 
    p data
  end
end

EventMachine::run do
  host = 'localhost'
  port = 8080
  EventMachine::start_server host, port, EchoServer
  puts "Started EchoServer on #{host}:#{port}.."
end
