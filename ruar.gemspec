# frozen_string_literal: true

require './lib/ruar/version'

Gem::Specification.new do |s|
  s.name        = 'ruar'
  s.version     = Ruar::VERSION
  s.summary     = 'Tar-like Archive for RIEN'
  s.description = 'Pack your Ruby code for distribution'

  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.0.0'

  s.license = 'Apache-2.0'

  s.authors  = ['Kowalski Dark']
  s.email    = ['darkkowalski2012@gmail.com']
  s.homepage = 'https://github.com/darkkowalski/ruar'

  s.files        = Dir['ext/**/*', 'lib/**/*', 'LICENSE', 'README.md']
  s.require_path = 'lib'
  s.extensions = ['ext/ruar/extconf.rb']

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/darkkowalski/ruar/issues'
  }

  s.add_development_dependency 'binding_of_caller', '~> 1.0.0'
  s.add_development_dependency 'minitest', '~> 5.14.3'
  s.add_development_dependency 'minitest-reporters', '~> 1.4.3'
  s.add_development_dependency 'rake', '~> 13.0.3'
  s.add_development_dependency 'rake-compiler', '~> 1.1.1'
  s.add_development_dependency 'rubocop', '~> 1.9.0'
  s.add_development_dependency 'rubocop-minitest', '~> 0.10.3'
  s.add_development_dependency 'rubocop-rake', '~>0.5.1'
end
