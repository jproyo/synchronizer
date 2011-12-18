require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/client/connector"

class ClientConnection
  
  def initialize(host, port)
    @host = host
    @port = port
  end

  def send_data(data)
    if !EventMachine::reactor_running?
	EventMachine::run do
	  @handler = EventMachine::connect @host, @port, Sender
	  @handler.sendPut
	  @handler.sendData data
	  @handler.closeConn
    	end
    end
  end

end

client = ClientConnection.new('localhost',8080)
client.send_data ARGV
