require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/client/connector"

class ClientConnection
  
  def initialize(host, port)
    @host = host
    @port = port
  end

  def connect
    if !@handler
	@handler = EventMachine::connect @host, @port, Sender
    end
    if @handler.error?
	@handler = EventMachine::connect @host, @port, Sender
    end
  end

  def send_data(data)
    if !EventMachine::reactor_running?
    	EventMachine::run do
		connect
		puts "Numero de Conexiones #{EventMachine::connection_count}"
		@handler.sendPut 
		@handler.sendData data
		@handler.closeConn
	end
    end
  end
  
end

client = ClientConnection.new('localhost',8080)
i = 0
data = []
while i < ARGV[0].to_i
	data << "Hola mundo"
	i = i + 1
end
client.send_data data

