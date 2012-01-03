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
    data_to_send = yield data
    EventMachine::run do
	connect data_to_send
    end
  end
  
end

client = ClientConnection.new('localhost',8080)
client.send_data ARGV[0] do |data| 
    complete_window = []
    bytes_msgs = IO.read(data).unpack('C*').to_a
    bytes_msgs.each_slice(10) do |slice|
    	complete_window << slice
    end
    complete_window
end

