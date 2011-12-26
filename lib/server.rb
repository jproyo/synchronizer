require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/data/message_protocol.pb"

module EchoServer 
  
  def post_init
	@data = Hash.new
  end
 
  def receive_data(data)
    BufferedTokenizer.new("MSG").extract(data).each do |msg|
    	process msg
    end
  end

  def process(bytes)
	begin
		helo = Messages::Helo.new.parse_from_string(bytes)
		@hello = helo
		p @hello
		rescue Exception
	end
	begin
		put = Messages::Put.new.parse_from_string(bytes)
		@put = put
		p @put
		rescue Exception
	end
	begin
		data = Messages::Data.new.parse_from_string(bytes)
		@data[data.chunkNumber] = data
		p data
		ack = Messages::Ack.new
		ack.chunkNumber = data.chunkNumber
		send_data ack.to_s 
		send_data "MSG"
		rescue Exception
	end
  end

  def unbind
    close_connection
  end


end

EventMachine::run do
  host = 'localhost'
  port = 8080
  EventMachine::start_server host, port, EchoServer
  puts "Started EchoServer on #{host}:#{port}.."
end
