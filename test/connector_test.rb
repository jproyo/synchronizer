require 'test/unit'
require 'mocha'
require "client/handler"

class TestMessage < Test::Unit::TestCase
  
  def test_is_not_ack
    ack = Messages::Ack.new
    ack.chunkNumber = 1
    ack.type = Messages::EndType::ACK_END 
    assert ack.is_not_ack?
  end
 
end

