require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/data/message_protocol.pb"

module EchoServer  
  def receive_data(data)
    BufferedTokenizer.new("MSG").extract(data).each do |msg|
    	process msg
    end
  end

  def process(bytes)
	begin
		helo = Messages::Helo.new.parse_from_string(bytes)
		p helo
		rescue Exception
	end
	begin
		put = Messages::Put.new.parse_from_string(bytes)
		p put
		rescue Exception
	end
	begin
		data = Messages::Data.new.parse_from_string(bytes)
		p data
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
