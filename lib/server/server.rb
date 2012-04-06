require 'rubygems'
require 'eventmachine'
require 'logger'
require 'digest/md5'
require 'data/message_protocol.pb'
require 'server/handler'

$LOG = Logger.new('server_log.log','daily')

EventMachine::run do
  host = ARGV[0]
  port = ARGV[1].to_i
  EventMachine::start_server host, port, SyncronizerHandler
  $LOG.info "Syncronizer Started on #{host}:#{port}.."
end
