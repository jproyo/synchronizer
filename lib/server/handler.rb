require 'rubygems'
require 'eventmachine'
require 'logger'
require 'digest/md5'
require 'data/message_protocol.pb'
require 'protocol'

#
# This is the Handler class of the Server Syncronizer Protocol
# This class handle requests from client and send back the appropiate response.
#
class SyncronizerHandler < EventMachine::Connection
  include Protocol
  
  def post_init
  end
 
  #See EventMachine::Connection::receive_data
  def receive_data(data)
    BufferedTokenizer.new($TOKEN).extract(data).each do |msg|
    	process msg
    end
  end

  #Parse from byte array into proper Protobuf Message Protocol
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

  #Close connection event
  def unbind
    close_connection
  end


  private
  #Send ACK to Client
  def sendAck
    $LOG.debug "Sending ACK"
    send_msg ack Messages::EndType::ACK
  end

  #Send END SUCCESS transmition to the client
  def sendEnd
    $LOG.debug "Sending END SUCCESS"
    send_msg ack Messages::EndType::ACK_END
  end

  #Alert the client to corrupt transmition data
  def sendDrop
    $LOG.debug "Sending DROP"
    send_msg ack Messages::EndType::DROP_END
  end

  #Build ACK Message
  def ack(type)
    ack = Messages::Ack.new
    ack.chunkNumber = last_chunk_number
    ack.type = type
    ack.to_s
  end

  #Is the End of Transmition?
  def is_end?
    last_chunk_number == amountChunks
  end

  #Is Data checksum verification ok?
  def checksum_ok?
    digest = Digest::MD5.hexdigest(File.read(@put.idTransaction))
    $LOG.debug "Checksum PUT #{@put.checkSum} - Received #{digest}"
    digest == @put.checkSum
  end

  #Write data into output
  def write_data(data)
    if last_chunk_number <= data.chunkNumber
	   IO.write(@put.idTransaction,data.data,data.chunkNumber*@helo.chunkSize)
    end
  end
  
  #Take the last chunk number received
  def last_chunk_number
    file_size = File.size(@put.idTransaction)
    file_size % @helo.chunkSize == 0 ? (file_size / @helo.chunkSize)-1 : file_size / @helo.chunkSize
  end

  #Process One chunk of data
  def processChunk(data)
    write_data data
    sendAck
    if is_end?
	   sendEnd if checksum_ok?
	   sendDrop if !checksum_ok?
    end
  end
 
  #Calculate the amount of chunks
  def amountChunks
    @put.msgSize % @helo.chunkSize == 0 ? (@put.msgSize/@helo.chunkSize)-1 : @put.msgSize/@helo.chunkSize
  end

end
