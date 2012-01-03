require 'rubygems'
require 'eventmachine'
require 'logger'
require 'digest/md5'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"
require "#{path}/../protocol"

class SyncronizerHandler < EventMachine::Connection
  include Protocol
  
  def post_init
	@data = Hash.new
  end
 
  def receive_data(data)
    BufferedTokenizer.new($TOKEN).extract(data).each do |msg|
    	process msg
    end
  end

  def process(bytes)
	begin
		helo = Messages::Helo.new.parse_from_string(bytes)
		@helo = helo
		$LOG.debug "Receive HELO message #{@helo.userId} - #{@helo.chunkSize}"
		rescue Exception
	end
	begin
		put = Messages::Put.new.parse_from_string(bytes)
		@put = put
		IO.sysopen(@put.idTransaction, "w+") if not File.exist?(@put.idTransaction)
		$LOG.debug "Receive PUT message #{@put.idTransaction} - #{@put.msgSize}"
		rescue Exception
	end
	begin
		data = Messages::Data.new.parse_from_string(bytes)
		$LOG.debug "Receive DATA #{data.chunkNumber}"
		processChunk data
		rescue Exception
	end
  end

  def unbind
    close_connection
  end


  private
 
  def sendAck
    $LOG.debug "Sending ACK"
    send_msg ack Messages::EndType::ACK
  end

  def sendFin
    $LOG.debug "Sending END SUCCESS"
    send_msg ack Messages::EndType::ACK_END
  end

  def sendDrop
    $LOG.debug "Sending DROP"
    send_msg ack Messages::EndType::DROP_END
  end

  def ack(type)
    ack = Messages::Ack.new
    ack.chunkNumber = last_chunk_number
    ack.type = type
    ack.to_s
  end

  def is_end?
    last_chunk_number == amountChunks
  end

  def checksum_ok?
    digest = Digest::MD5.hexdigest(File.read(@put.idTransaction))
    $LOG.debug "Checksum PUT #{@put.checkSum} - Received #{digest}"
    digest == @put.checkSum
  end

  def write_data(data)
    if last_chunk_number <= data.chunkNumber
	IO.write(@put.idTransaction,data.data,data.chunkNumber*@helo.chunkSize)
    end
  end
 
  def last_chunk_number
    file_size = File.size(@put.idTransaction)
    file_size % @helo.chunkSize == 0 ? (file_size / @helo.chunkSize)-1 : file_size / @helo.chunkSize
  end

  def processChunk(data)
    write_data data
    sendAck
    if is_end?
	sendFin if checksum_ok?
	sendDrop if !checksum_ok?
    end
  end

  def amountChunks
    @put.msgSize % @helo.chunkSize == 0 ? (@put.msgSize/@helo.chunkSize)-1 : @put.msgSize/@helo.chunkSize
  end

end
