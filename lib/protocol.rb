require 'rubygems'
require 'eventmachine'

module Protocol
  
  $TOKEN = "MSG"

  def send_msg(data)
    if not error?	
	self.send_data data
	self.send_data $TOKEN
    end
  end
end
