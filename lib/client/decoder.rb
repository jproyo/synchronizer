require 'rubygems'
require 'eventmachine'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"

class Decoder

  $TOKEN = "MSG"
  
  def self.decode(data)
   deco = Hash.new
   BufferedTokenizer.new($TOKEN).extract(data).each do |msg|
        ack = Messages::Ack.new.parse_from_string(msg)
        deco[:ack] = ack
        $LOG.debug "Recibing ACK #{ack.chunkNumber}"
   end 
   deco
  end

end
