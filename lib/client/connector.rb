require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"

class Messages::Ack
	def is_not_ack?
		is_end? or is_drop?		
	end
	def is_end?
		type == Messages::EndType::ACK_END
	end
	def is_drop?
		type == Messages::EndType::DROP_END
	end
end

class Sender < EventMachine::Connection

  $TOKEN = "MSG"

  def initialize *args
	super
	@complete_window = args[0]
	@host = args[1]
	@port = args[2]
	@reconnect_timer = 5
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
		super $TOKEN
	end
  end

  def receive_data(data)
    BufferedTokenizer.new($TOKEN).extract(data).each do |msg|
        @ack = Messages::Ack.new.parse_from_string(msg)
        $LOG.debug "Recibing ACK #{@ack.chunkNumber}"
    	if @ack.is_not_ack?
	      @fin = true
	      $LOG.debug "Process Finished!!!" if @ack.is_end?
	      $LOG.error "There have been problems with the transfer. Please resend the data" if @ack.is_drop?
	      finish_handshake
	end
    end
    if not @fin and @ack.chunkNumber > @index
	$LOG.debug "Ack #{@ack.chunkNumber}. Moving window forward"
	@index = @ack.chunkNumber
    end
    sendData if not @fin
  end
  
  def finish_handshake
	if @timer
		@timer.cancel
		@timer = nil
	end
	close_connection_after_writing
  end

  def unbind 
    if not @fin and not @timer
	@timer = EventMachine::PeriodicTimer.new(@reconnect_timer) do
		$LOG.debug "Connetion has been lost. Trying to reconnect every #{@reconnect_timer} seconds.."
    		reconnect @host, @port
		send_init_data
	end 
    elsif not @timer
    	$LOG.debug 'Finish. Closing connection.'
	EventMachine::stop_event_loop
    end
  end
end
