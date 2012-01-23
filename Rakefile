# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'yard'
require 'rspec/core/rake_task'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "jogger"
  gem.homepage = "http://github.com/jayniz/jogger"
  gem.license = "MIT"
  gem.summary = %Q{Pacer traversals for lazy people}
  gem.description = %Q{Allows to group traversal fragments/pipes to named traversals and call them like they were pacer pipes.}
  gem.email = "jannis@gmail.com"
  gem.authors = ["Jannis Hermanns"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

#
#  RSpec
#
task :default => [:spec]
task :test => [:spec]
desc "run spec tests"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*_spec.rb'
end


#
#  Yard
#
desc 'Generate documentation'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', '-', 'LICENSE']
  t.options = ['--main', 'README.md', '--no-private']
end

