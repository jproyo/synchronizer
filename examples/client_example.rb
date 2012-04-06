require 'client/client'

client = ClientConnection.new('localhost',8080)
client.send_data ARGV[0] do |data| 
    complete_window = []
    bytes_msgs = IO.read(data).unpack('C*').to_a
    bytes_msgs.each_slice(10) do |slice|
    	complete_window << slice
    end
    complete_window
end