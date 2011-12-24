require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"

class Sender < EventMachine::Connection
  def post_init
    helo = Messages::Helo.new
    helo.userId = 54
    helo.chunkSize = 544
    send_data helo.to_s
  end

  def sendData(messages)
    @complete_window = messages
    @buffered_window = @complete_window
    messages.each_with_index do |msg, index|
	data = Messages::Data.new
	data.chunkNumber = index
	data.data = msg
	send_data data.to_s
    end
  end
    

  def sendPut
	put = Messages::Put.new
	put.idTransaction = rand(0...1000).to_s
	put.msgSize = 1111
	put.checkSum = "AB3123AB3213212313"
	send_data put.to_s
  end

  def send_data(data)
	if not error?	
		super data
		super "MSG"
	end
  end

  def closeConn
	close_connection true
  end
  
  def receive_data(data)
    @data = data
    puts @data
  end

  def unbind
    puts 'Connection was closed.'
    EventMachine::stop_event_loop
  end
end
