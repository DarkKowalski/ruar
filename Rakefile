# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/extensiontask'

gemspec = Gem::Specification.load('ruar.gemspec')

Rake::ExtensionTask.new('ruar', gemspec) do |ext|
  ext.ext_dir = 'ext/ruar'
  ext.lib_dir = 'lib/ruar'
end

require 'rake/testtask'
require 'ci/reporter/rake/minitest'

Rake::TestTask.new(:minitest) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
end

Gem::PackageTask.new(gemspec) do |pkg|
end

task test: 'ci:setup:minitest'
task default: %w[compile test]
