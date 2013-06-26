$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'functional/version'

Gem::Specification.new do |s|
  s.name        = 'functional-ruby'
  s.version     = Functional::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Jerry D'Antonio"
  s.email       = 'jerry.dantonio@gmail.com'
  s.homepage    = 'https://github.com/jdantonio/functional-ruby/'
  s.summary     = 'Erlang and Clojure inspired functional programming tools for Ruby.'
  s.license     = 'MIT'
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.description = <<-EOF
    A gem for adding Erlang and Clojure inspired functional programming tools to Ruby.
  EOF

  s.files            = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.files           += Dir['{lib,spec}/**/*']
  s.test_files       = Dir['{spec}/**/*']
  s.extra_rdoc_files = ['README.md']
  s.extra_rdoc_files = Dir['README*', 'LICENSE*', 'CHANGELOG*']
  s.require_paths    = ['lib']

  s.required_ruby_version = '>= 1.9.2'
  s.post_install_message  = <<-MSG
    hello() -> io:format("Hello, World!").

    package main
    import "fmt"
    func main() {
      fmt.Printf("hello, world")
    }

    (def hello (fn [] "Hello world"))
  MSG

  s.add_development_dependency 'bundler'
end
