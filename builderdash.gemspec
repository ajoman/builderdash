# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'dash/version'

Gem::Specification.new do |spec|
  spec.name          = 'builderdash'
  spec.version       = Dash::VERSION
  spec.summary       = 'A build gem for iOS and Android platforms'
  spec.description   = <<-EOF
    A build gem for iOS and Android platforms.
    The name is inspired by the mighty Boulder Dash computer games.
  EOF
  spec.authors       = [ 'Sergi Hernando' ]
  spec.email         = [ 'sergi.hernando@speedjab.com' ]
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = [ 'lib' ]
  spec.homepage      = 'https://github.com/ajoman/builderdash'
  spec.license       = 'LGPL'

  spec.required_ruby_version = '~> 2.0.0'

  spec.add_development_dependency 'rake', '~> 12.3'

  spec.add_dependency 'fog', '~> 1.18', '>= 1.18.0'
  spec.add_dependency 'mustache', '~> 0.99', '>= 0.99.5'
  spec.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.1'
end
