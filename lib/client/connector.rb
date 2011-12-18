require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"

class Sender < EventMachine::Connection
  def post_init
    helo = Messages::Helo.new
    helo.userId = 12
    helo.chunkSize = 512
 
    send_data helo.to_s
    
    put = Messages::Put.new
    put.idTransaction = rand(0...1000).to_s
    put.msgSize = 1024
    put.checkSum = "AB3123AB3213212313"
    send_data put.to_s
    
    ARGV.each_with_index do |msg, index|
  	data = Messages::Data.new
	data.chunkNumber = index
	data.data = msg
	send_data data.to_s
    end
    close_connection true
  end
  
  def receive_data(data)
    @data << data
    puts @data
  end

  def unbind 
    EventMachine::stop_event_loop
    puts 'Connection server was closed'
    
  end
end
