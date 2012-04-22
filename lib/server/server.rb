require 'rubygems'
require 'eventmachine'
require 'logger'
require 'server/handler'

$LOG = Logger.new('server_log.log','daily')

class Server

	def initialize(host, port)
		@host = host
		@port = port
	end

	def start
		EventMachine::run do
		  EventMachine::start_server @host, @port, SyncronizerHandler
		  $LOG.info "Syncronizer Started on #{@host}:#{@port}.."
		end
	end

end
