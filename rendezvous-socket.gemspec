# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rendezvous/socket/version'

Gem::Specification.new do |spec|
  spec.name          = "rendezvous-socket"
  spec.version       = Rendezvous::Socket::VERSION
  spec.authors       = ["Michael Hale"]
  spec.email         = ["mike@hales.ws"]
  spec.description   = File.read('README.md').match(/\A#\s+[^\n]+\n+([\W\w]+?)\n+##/)[1].chomp # http://rubular.com/r/vzsBvug0GC
  spec.summary       = %q{A ruby socket object which attempts to establish a P2P connection}
  spec.homepage      = "https://github.com/mikehale/rendezvous-socket/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
