$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'pattern_matching/version'

Gem::Specification.new do |s|
  s.name        = 'pattern-matching'
  s.version     = PatternMatching::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Jerry D'Antonio"
  s.email       = 'jerry.dantonio@gmail.com'
  s.homepage    = 'https://github.com/jdantonio/pattern_matching/'
  s.summary     = 'Erlang-style function/method overloading through pattern matching for Ruby classes.'
  s.license     = 'MIT'
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.description = <<-EOF
    A gem for adding Erlang-style function/method overloading through pattern matching to Ruby classes.

    For fun I've also thrown in Erlang's sparsely documented -behaviour
    functionality plus a few other functions and constants I find useful.
  EOF

  s.files            = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.files           += Dir['{lib,spec}/**/*']
  s.test_files       = Dir['{spec}/**/*']
  s.extra_rdoc_files = ['README.md']
  s.extra_rdoc_files = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.require_paths    = ['lib']

  s.required_ruby_version = '>= 1.9.2'
  s.post_install_message  = 'start() -> io:format("Hello, World!").'

  s.add_development_dependency 'bundler'
end
