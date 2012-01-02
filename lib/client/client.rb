require 'rubygems'
require 'eventmachine'
require 'logger'
path = File.dirname(__FILE__)
require "#{path}/connector"

$LOG = Logger.new('client_log.log','daily')

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

