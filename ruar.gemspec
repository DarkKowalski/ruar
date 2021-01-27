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

  s.files        = Dir['lib/**/*', 'LICENSE', 'README.md']
  s.require_path = 'lib'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/darkkowalski/ruar/issues'
  }

  s.add_development_dependency 'rake', '~> 13.0.3'
  s.add_development_dependency 'minitest', '~> 5.14.3'
  s.add_development_dependency 'ci_reporter_minitest', '~> 1.0.0'
end
