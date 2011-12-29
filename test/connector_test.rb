require 'test/unit'
path = File.dirname(__FILE__)
require "#{path}/../lib/client/connector"

class TestSender < Test::Unit::TestCcase
  
  def test_hasmore
    sender = Sender.new(["Hola"],"localhost", 9090)
    assert_true sender.hasMore
  end
 
end

