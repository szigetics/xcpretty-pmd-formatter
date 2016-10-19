# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'xcpretty-pmd-formatter'
  spec.version       = '0.0.3'
  spec.authors       = ['Csaba Szigeti']
  spec.email         = ['szigetics@gmail.com']

  spec.summary       = 'xcpretty custom formatter for parsing warnings and static analyzer issues easily from "xcodebuild ... clean build analyze" output'
  spec.description   = 'Custom formatter for xcpretty that saves on a PMD file all the errors, and warnings, so you can process them easily later.'
  spec.homepage      = 'https://github.com/szigetics/xcpretty-pmd-formatter'
  spec.license       = 'MIT'

  spec.files         = [
    'README.md',
    'LICENSE',
    'lib/pmd_formatter.rb',
    'bin/xcpretty-pmd-formatter'
  ]
  spec.executables   = ['xcpretty-pmd-formatter']
  spec.require_paths = ['lib']

  spec.add_dependency 'xcpretty', '~> 0.2', '>= 0.0.7'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.38'
  spec.add_development_dependency 'libxml-ruby', '~> 2.9.0'
end
