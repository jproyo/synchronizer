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
