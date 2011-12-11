require 'rubygems'
require 'eventmachine'

class Helo
  def to_s
	"HEL 1"
  end
end

class Put
  def to_s
	"PUT OPER:1"
  end
end

class Data
  
class << self
  def send_message(conn, msg)
    msg.chars.each_with_index do |chunk,index|
	puts "DATA #{index} #{chunk}"
	conn.send_data "DATA #{index} #{chunk}"
    end
  end
end

end

module SyncroClient 
  def post_init
    send_data Helo.new
    send_data Put.new
    Data.send_message self, "Hola Juan Pablo"
    @data = ""
  end
  
  def receive_data(data)
    @data << data
    puts @data
  end
end

EventMachine::run do
  EventMachine::connect 'localhost', 8080, SyncroClient
end
