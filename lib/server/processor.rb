require 'rubygems'
require 'eventmachine'
require 'logger'
require 'digest/md5'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"

class Syncronizer < EventMachine::Connection
  
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
		@fd = IO.sysopen(@put.idTransaction, "w+")
		$LOG.debug "Receive PUT message #{@put.idTransaction}"
		rescue Exception
	end
	begin
		data = Messages::Data.new.parse_from_string(bytes)
		@data[data.chunkNumber] = data
		IO.write(@put.idTransaction,data.data,data.chunkNumber*@helo.chunkSize)
		$LOG.debug "Sending DATA #{data.chunkNumber}"
		ack = Messages::Ack.new
		ack.chunkNumber = data.chunkNumber
		ack.type = Messages::EndType::ACK
		$LOG.debug "Seding ack #{ack.chunkNumber}"
		send_data ack.to_s 
		send_data "MSG"
		if data.chunkNumber == amountChunks
			digest = Digest::MD5.hexdigest(File.read(@put.idTransaction))
			if digest == @put.checkSum
				$LOG.debug "Sending fin_ack"
				fin_ack = Messages::Ack.new
				fin_ack.chunkNumber = data.chunkNumber
				fin_ack.type = Messages::EndType::ACK_END
				send_data fin_ack.to_s
				send_data "MSG"
			else
				$LOG.debug "Sending fin drop.Checksum PUT #{@put.checksum} - Checksum received #{digest}"
				fin_drop = Messages::Ack.new
				fin_drop.chunkNumber = data.chunkNumber
				fin_drop.type = Messages::EndType::ACK_DROP
				send_data fin_drop.to_s
				send_data "MSG"
			end
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
