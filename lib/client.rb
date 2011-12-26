require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/client/connector"

class ClientConnection
  
  def initialize(host, port)
    @host = host
    @port = port
  end

  def connect(data)
    @handler = EventMachine::connect @host, @port, Sender, data, @host, @port
  end

  def send_data(data)
    EventMachine::run do
	connect data
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

