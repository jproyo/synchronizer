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



module SyncroClient 
  def post_init
    send_data Helo.new
    @data = ""
  end
  
  def receive_data(data)
    @data << data
    puts @data
    send_data Put.new
  end
  
  #def unbind
  #  if @data =~ /[\n][\r]*[\n]/m
  #    $`.each {|line| puts ">>> #{line}" }
  #  end
  #  
  #  EventMachine::stop_event_loop
  #end
end

EventMachine::run do
  EventMachine::connect 'localhost', 8080, SyncroClient
end

