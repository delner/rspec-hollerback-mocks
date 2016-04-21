source 'https://rubygems.org'

# Get local or master 'hollerback' gem
library_path = File.expand_path("../../hollerback", __FILE__)
if File.exist?(library_path)
  gem 'hollerback', path: library_path
else
  gem 'hollerback', git: "git://github.com/delner/hollerback.git",
                    branch: ENV.fetch('BRANCH',"master")
end

gem "rspec", :git => "git://github.com/rspec/rspec.git"
gem "rspec-core", :git => "git://github.com/rspec/rspec-core.git"
gem "rspec-expectations", :git => "git://github.com/rspec/rspec-expectations.git"
gem "rspec-mocks", :git => "git://github.com/rspec/rspec-mocks.git"
gem "rspec-support", :git => "git://github.com/rspec/rspec-support.git"

gem "pry-stack_explorer"

gemspec
