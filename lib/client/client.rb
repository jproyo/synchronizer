require 'rubygems'
require 'eventmachine'
require 'logger'
require 'client/handler'

$LOG = Logger.new('client_log.log','daily')

# ClientConnection class is the first entry point to send data to a syncronizer server.
# Instantiate this class and pass as an argument the host and port server you want to connect to.
class ClientConnection
  
  def initialize(host, port)
    @host = host
    @port = port
  end

  # Send any data that you want to a server syncronizer.
  # This method receives a proc too in order to build the byte array as the client wants.
  # The client has the responsability to build in the block proc an array of byte's array
  # where the length of the main array is the amount of chunks to be transfer to the server.
  # Example:
  #	client = ClientConnection.new('localhost',8080)
  #	client.send_data ARGV[0] do |data|
  #  		complete_window = []
  #  		bytes_msgs = IO.read(data).unpack('C*').to_a
  #  		bytes_msgs.each_slice(10) do |slice|
  #     		complete_window << slice
  #  		end
  #  		complete_window
  #	end
  #
  # In this example we are reading from a file and building chunks of 10 bytes to be sent
  def send_data(data)
    data_to_send = yield data
    EventMachine::run do
        connect data_to_send
    end
  end


  private 
  def connect(data)
  	EventMachine::connect @host, @port, SenderHandler, data, @host, @port
  end

end