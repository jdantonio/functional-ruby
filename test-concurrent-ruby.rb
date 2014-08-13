require 'functional'

atomic = Concurrent::Atomic.new(42)
tuple = Functional::Tuple.new([atomic])

puts tuple.inspect
puts atomic.inspect

__END__

[06:58:36 Jerry ~/Projects/FOSS/functional-ruby (testing-concurrent-ruby-bug)]
$ rvm use rbx-2.2.10@test --create
rbx-2.2.10 - #gemset created /Users/Jerry/.rvm/gems/rbx-2.2.10@test
rbx-2.2.10 - #generating test wrappers..........
Using /Users/Jerry/.rvm/gems/rbx-2.2.10 with gemset test

[06:58:53 Jerry ~/Projects/FOSS/functional-ruby (testing-concurrent-ruby-bug)]
$ bundle install
Fetching gem metadata from https://rubygems.org/.........
Resolving dependencies...
Using rake 10.3.2
Using bundler 1.6.2
Installing docile 1.1.5
Installing multi_json 1.10.1
Installing simplecov-html 0.8.0
Installing simplecov 0.9.0
Installing codeclimate-test-reporter 0.3.0
Installing concurrent-ruby 0.7.0.rc2
Installing mime-types 2.3
Installing netrc 0.7.7
Installing rest-client 1.7.2
Installing tins 1.3.0
Installing term-ansicolor 1.3.0
Installing thor 0.19.1
Installing coveralls 0.7.0
Installing diff-lcs 1.2.5
Using functional-ruby 1.1.0.test1 from source at .
Installing rspec-support 3.0.2
Installing rspec-core 3.0.2
Installing rspec-expectations 3.0.2
Installing rspec-mocks 3.0.2
Installing rspec 3.0.0
Installing yard 0.8.7.4
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.

[06:59:49 Jerry ~/Projects/FOSS/functional-ruby (testing-concurrent-ruby-bug)]
$ gem build functional_ruby.gemspec
WARNING:  prerelease dependency on concurrent-ruby (= 0.7.0.rc2) is not recommended
WARNING:  open-ended dependency on bundler (>= 0, development) is not recommended
  if bundler is semantically versioned, use:
    add_development_dependency 'bundler', '~> 0'
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
  Successfully built RubyGem
  Name: functional-ruby
  Version: 1.1.0.test1
  File: functional-ruby-1.1.0.test1.gem

[06:59:57 Jerry ~/Projects/FOSS/functional-ruby (testing-concurrent-ruby-bug)]
$ ls
CHANGELOG.md                    README.md                       doc                             pkg                             yardoc
Gemfile                         Rakefile                        functional-ruby-1.1.0.test1.gem spec
Gemfile.lock                    coverage                        functional_ruby.gemspec         tasks
LICENSE                         critic                          lib                             test-concurrent-ruby.rb

[07:00:01 Jerry ~/Projects/FOSS/functional-ruby (testing-concurrent-ruby-bug)]
$ gem install functional-ruby-1.1.0.test1.gem
Successfully installed functional-ruby-1.1.0.test1
1 gem installed

[07:00:19 Jerry ~/Projects/FOSS/functional-ruby (testing-concurrent-ruby-bug)]
$ ruby ./test-concurrent-ruby.rb
#<Functional::Tuple: [#<Concurrent::Atomic:0x15c8>]>
#<Concurrent::Atomic:0x15c8>

