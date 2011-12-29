require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"

class Messages::Ack
	def is_not_ack
		type == Messages::EndType::ACK_END or type == Messages::EndType::DROP_END
	end
end

class Sender < EventMachine::Connection

  def initialize *args
	super
	@complete_window = args[0]
	@host = args[1]
	@port = args[2]
  end

  def post_init
	send_init_data
  end

  def send_init_data
	@fin = false
	@index = 0
	@number = 0
	sendHelo unless error?
	sendPut unless error?
	sendData unless error?
  end
  
  def sendHelo
    helo = Messages::Helo.new
    helo.userId = 54
    helo.chunkSize = 1
    send_data helo.to_s
  end
  
  def sendData
    @buffered_window = @complete_window[@index..@index+2]
    @index += 3
    if hasMore
	@buffered_window.each do |msg|
		data = Messages::Data.new
		data.chunkNumber = @number
		data.data = Marshal.dump(msg)
		send_data data.to_s
		@number += 1
	end
	@buffered_window.clear
    end
  end
  
  def hasMore
	if @buffered_window
		not @buffered_window.empty?
	else
		false
	end
  end

  def sendPut
	put = Messages::Put.new
	put.idTransaction = rand(0...1000).to_s
	put.msgSize = @complete_window.length
	put.checkSum = "AB3123AB3213212313"
	send_data put.to_s
  end

  def send_data(data)
	if not error?	
		super data
		super "MSG"
	end
  end

  def receive_data(data)
    BufferedTokenizer.new("MSG").extract(data).each do |msg|
        ack = Messages::Ack.new.parse_from_string(msg)
	@ack = ack
	p ack
	if ack.is_not_ack
		@fin = true
		puts "Process Finished!!!" if ack.type == Messages::EndType::ACK_END
		puts "There have been problems with the transfer. Please resend the data" if ack.type == Messages::EndType::DROP_END
		close_connection_after_writing
	end
    end
    if not @fin and @ack.chunkNumber > @index
	puts "Ack #{@ack.chunkNumber}. Moving window forward"
	@index = @ack.chunkNumber
    end
    sendData if not @fin
  end

  def unbind 
    if not @fin
	puts "Connection was closed. Trying to reconnect...."
    	reconnect @host, @port
	send_init_data
    else
    	puts 'Finish. Closing connection.'
	EventMachine::stop_event_loop
    end
  end
end
