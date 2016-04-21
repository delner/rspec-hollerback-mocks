# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/hollerback/mocks/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-hollerback-mocks"
  spec.version       = RSpec::Hollerback::Mocks::VERSION
  spec.authors       = ["David Elner"]
  spec.email         = ["david@davidelner.com"]

  spec.summary       = %q{RSpec mocks for Hollerback.}
  spec.homepage      = "https://github.com/delner/rspec-hollerback-mocks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "rspec-mocks", "~> 3.0"
  spec.add_runtime_dependency     "hollerback", "~> 0.1"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec", "~> 3.0"
end
