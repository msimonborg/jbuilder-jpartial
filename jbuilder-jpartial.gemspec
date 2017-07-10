# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jbuilder/jpartial/version'

Gem::Specification.new do |spec|
  spec.name          = 'jbuilder-jpartial'
  spec.version       = Jbuilder::Jpartial::VERSION
  spec.authors       = ['M. Simon Borg']
  spec.email         = ['msimonborg@gmail.com']

  spec.summary       = 'Simple DSL for faster partial rendering with Jbuilder'
  spec.description   = 'Simple DSL for faster partial rendering with Jbuilder'
  spec.homepage      = 'https://github.com/msimonborg/jbuilder-jpartial'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z lib LICENSE.txt README.md`.split("\0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'jbuilder', '>= 2.1'

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
