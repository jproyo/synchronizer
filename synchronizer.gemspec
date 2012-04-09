Gem::Specification.new do |s|
  s.name        = 'synchronizer'
  s.version     = '0.0.1'
  s.date        = '2012-04-09'
  s.summary     = "Synchronizer big content among nodes"
  s.description = "This is a gem that helps you to synchronize big amount of data, between nodes, supporting reconnection in bad performance networks"
  s.authors     = ["Juan Pablo Royo"]
  s.email       = 'juanpablo.royo@gmail.com'
  s.files       = Dir["lib/**/*.rb"]
  s.add_dependency "eventmachine", "~>0.12.10"
  s.add_dependency "ruby_protobuf", "~>0.4.11"
  s.homepage    = 'http://rubygems.org/gems/hola'
end