require 'bundler/gem_tasks'
require 'reek/rake/task'
require 'rubocop/rake_task'
require 'rubocop'
require 'rspec/core/rake_task'
require 'yard'

task :default => [:build, :test]
task :inspect => [:reek, :rubocop]

RSpec::Core::RakeTask.new(:spec)
task :test => :spec

Reek::Rake::Task.new do |task| # :reek
  task.name = :reek
  task.source_files = 'lib/**/*.rb'
  task.fail_on_error = false
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  task.fail_on_error = false
end

YARD::Rake::YardocTask.new do |task| # :yard
  task.files = %w(lib/**/*.rb - *.md)
end
task :doc => :yard
