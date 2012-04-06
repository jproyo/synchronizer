require 'rake'
require 'rake/testtask'
 
task :default => [:test_units]
 
desc "Running Unit Test"
Rake::TestTask.new("test_units") { |t|
	t.libs << 'lib'
  	t.pattern = 'test/*_test.rb'
	t.verbose = true
  	t.warning = true
}

desc "Run Server Example"
task :run_server => :test_units do
	exec 'ruby -I lib lib/server/server.rb localhost 8080'
end

desc "Run Client Example. CHECK IF THE SERVER IS RUNNING!!!"
task :run_client => :test_units do
	exec 'ruby -I lib examples/client_example.rb examples/hello.txt'
end