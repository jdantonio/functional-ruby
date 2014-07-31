$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'functional/version'

Gem::Specification.new do |s|
  s.name        = 'functional-ruby'
  s.version     = Functional::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Jerry D'Antonio"
  s.email       = 'jerry.dantonio@gmail.com'
  s.homepage    = 'https://github.com/jdantonio/functional-ruby/'
  s.summary     = 'Erlang, Clojure, Haskell, and Functional Java inspired functional programming tools for Ruby.'
  s.license     = 'MIT'
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.description = <<-EOF
    A gem for adding functional programming tools to Ruby. Inspired by Erlang, Clojure, Haskell, and Functional Java.
  EOF

  s.files             = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.files            += Dir['{lib}/**/*']
  s.test_files        = Dir['{spec}/**/*']
  s.extra_rdoc_files  = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.extra_rdoc_files += Dir['{doc}/**/*.{txt,md}']
  s.require_paths     = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency 'bundler'
end
