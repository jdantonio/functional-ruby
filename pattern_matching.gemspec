$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'pattern_matching/version'
require 'date'
require 'rbconfig'

Gem::Specification.new do |s|
  s.name        = 'pattern_matching'
  s.version     = PatternMatching::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Jerry D'Antonio"
  s.email       = 'jerry.dantonio@gmail.com'
  s.homepage    = 'https://github.com/jdantonio/pattern_matching/'
  s.summary     = 'Erlang-style pattern matching to Ruby.'
  s.license     = 'MIT'
  s.date        = Date.today.to_s

  s.description = <<-EOF
    A gem for adding Erlang-style pattern matching to Ruby.
  EOF

  s.files            = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.files           += Dir['{lib,spec}/**/*']
  s.test_files       = Dir['{spec}/**/*']
  s.extra_rdoc_files = ['README.md']
  s.extra_rdoc_files = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.require_paths    = ['lib']

  s.required_ruby_version = '>= 1.9.2'
  s.post_install_message  = 'Happy matching!'

  s.add_development_dependency 'bundler'
end
