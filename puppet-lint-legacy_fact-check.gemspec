Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-legacy_fact-check'
  spec.version     = '0.1.0'
  spec.homepage    = 'https://github.com/ekohl/puppet-lint-legacy_fact-check'
  spec.license     = 'MIT'
  spec.author      = 'Ewoud Kohl van Wijngaarden'
  spec.email       = 'ewoud+rubygems@kohlvanwijngaarden.nl'
  spec.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.test_files  = Dir['spec/**/*']
  spec.summary     = 'A puppet-lint plugin to check for legacy facts.'
  spec.description = <<-EOF
    A puppet-lint plugin to check that manifest files don't use legacy facts.
  EOF

  spec.add_dependency             'puppet-lint', '~> 2.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rake'
end
