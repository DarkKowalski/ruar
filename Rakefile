# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/extensiontask'

gemspec = Gem::Specification.load('ruar.gemspec')

Rake::ExtensionTask.new('ruar', gemspec) do |ext|
  ext.ext_dir = 'ext/ruar'
  ext.lib_dir = 'lib/ruar'
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

Gem::PackageTask.new(gemspec) do |pkg|
  # If no block is supplied, then define needs to be called to define the task.
end

task default: %w[compile test]
