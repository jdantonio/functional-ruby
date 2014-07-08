$:.push File.join(File.dirname(__FILE__), 'lib')

GEMSPEC = Gem::Specification.load('functional-ruby.gemspec')

require 'bundler/gem_tasks'
require 'rspec'
require 'rspec/core/rake_task'

require 'functional'

Bundler::GemHelper.install_tasks

Dir.glob('tasks/**/*.rake').each do|rakefile|
  load rakefile
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--color --backtrace --format documentation'
end

RSpec::Core::RakeTask.new(:travis_spec) do |t|
  t.rspec_opts = '--tag ~@not_on_travis'
end

task :default => [:travis_spec]
