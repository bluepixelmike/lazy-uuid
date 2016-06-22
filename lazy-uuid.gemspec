# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lazy-uuid/version'

Gem::Specification.new do |spec|
  spec.name          = 'lazy-uuid'
  spec.version       = LazyUuid::VERSION
  spec.authors       = ['Michael Miller']
  spec.email         = ['bluepixelmike@gmail.com']

  spec.summary       = %q{Small gem for creating and using UUIDs (universally unique identifier).}
  spec.description   = %q{Generates RFC 4122 compliant UUIDs.
These UUIDs can be treated as their raw byte representation or as human-readable strings.}
  spec.homepage      = 'https://github.com/bluepixelmike/lazy-uuid'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'bin'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = spec.files.grep(%r{^bin/.*uuid}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'factory_girl', '~> 4.0'
  spec.add_development_dependency 'reek', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.38.0'
  spec.add_development_dependency 'codeclimate-test-reporter' unless RUBY_PLATFORM == 'java'
  spec.add_development_dependency 'yard'
end
