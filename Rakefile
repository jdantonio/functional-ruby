$:.push File.join(File.dirname(__FILE__), 'lib')
$:.push File.join(File.dirname(__FILE__), 'tasks/support')

require 'rubygems'
require 'bundler/gem_tasks'
require 'rspec'
require 'rspec/core/rake_task'
require 'yard'

require 'functional/all'

Bundler::GemHelper.install_tasks
YARD::Rake::YardocTask.new do |t|
  #t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  #t.options = ['--any', '--extra', '--opts'] # optional
end

$:.unshift 'tasks'
Dir.glob('tasks/**/*.rake').each do|rakefile|
  load rakefile
end

task :default => [:spec]
