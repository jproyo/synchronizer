require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/client/connector"

class ClientConnection
  
  def initialize(host, port)
    @host = host
    @port = port
    if !EventMachine::reactor_running?
	EventMachine::run do
	  EventMachine::connect @host, @port, Sender
	end
    end
  end

  def send_data(data)
    
  end

end

ClientConnection.new('localhost',8080)
