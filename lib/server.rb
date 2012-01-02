require 'rubygems'
require 'eventmachine'
require 'logger'
path = File.dirname(__FILE__)
require "#{path}/data/message_protocol.pb"

$LOG = Logger.new('server_log.log','daily')

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
		@helo = helo
		$LOG.debug "Receive HELO message #{@helo.userId}"
		rescue Exception
	end
	begin
		put = Messages::Put.new.parse_from_string(bytes)
		@put = put
		$LOG.debug "Receive PUT message #{@put.idTransaction}"
		rescue Exception
	end
	begin
		data = Messages::Data.new.parse_from_string(bytes)
		@data[data.chunkNumber] = data
		$LOG.debug "Sending DATA #{data.chunkNumber}"
		ack = Messages::Ack.new
		ack.chunkNumber = data.chunkNumber
		ack.type = Messages::EndType::ACK
		$LOG.debug "Seding ack #{ack.chunkNumber}"
		send_data ack.to_s 
		send_data "MSG"
		if data.chunkNumber == amountChunks
			$LOG.debug "Seding fin_ack"
			fin_ack = Messages::Ack.new
			fin_ack.chunkNumber = data.chunkNumber
			fin_ack.type = Messages::EndType::ACK_END
			send_data fin_ack.to_s
			send_data "MSG"
		end
		rescue Exception
	end
  end

  def amountChunks
	@put.msgSize % @helo.chunkSize == 0 ? (@put.msgSize/@helo.chunkSize)-1 : @put.msgSize/@helo.chunkSize
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
