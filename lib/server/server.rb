require 'rubygems'
require 'eventmachine'
require 'logger'
require 'digest/md5'
path = File.dirname(__FILE__)
require "#{path}/../data/message_protocol.pb"
require "#{path}/processor"

$LOG = Logger.new('server_log.log','daily')

EventMachine::run do
  host = ARGV[0]
  port = ARGV[1].to_i
  EventMachine::start_server host, port, Syncronizer
  puts "Syncronizer Started on #{host}:#{port}.."
end
