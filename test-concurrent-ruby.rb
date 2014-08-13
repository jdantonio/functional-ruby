require 'functional'

atomic = Concurrent::Atomic.new(42)
tuple = Functional::Tuple.new([atomic])

puts tuple.inspect
puts atomic.inspect

__END__

[07:47:30 Jerry ~/Projects/FOSS/functional-ruby (test-2-concurrent-ruby-bug)]
$ rvm use rbx-2.2.10@test --create
rbx-2.2.10 - #gemset created /Users/Jerry/.rvm/gems/rbx-2.2.10@test
rbx-2.2.10 - #generating test wrappers..........
Using /Users/Jerry/.rvm/gems/rbx-2.2.10 with gemset test

[07:47:38 Jerry ~/Projects/FOSS/functional-ruby (test-2-concurrent-ruby-bug)]
$ bundle install
Fetching gem metadata from https://rubygems.org/.........
Resolving dependencies...
Using rake 10.3.2
Installing atomic 1.1.16
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
Using functional-ruby 1.1.0.test2 from source at .
Installing rspec-support 3.0.2
Installing rspec-core 3.0.2
Installing rspec-expectations 3.0.2
Installing rspec-mocks 3.0.2
Installing rspec 3.0.0
Installing yard 0.8.7.4
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.

[07:48:38 Jerry ~/Projects/FOSS/functional-ruby (test-2-concurrent-ruby-bug)]
$ gem build functional_ruby.gemspec
WARNING:  prerelease dependency on concurrent-ruby (= 0.7.0.rc2) is not recommended
WARNING:  open-ended dependency on bundler (>= 0, development) is not recommended
  if bundler is semantically versioned, use:
    add_development_dependency 'bundler', '~> 0'
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
  Successfully built RubyGem
  Name: functional-ruby
  Version: 1.1.0.test2
  File: functional-ruby-1.1.0.test2.gem

[07:48:44 Jerry ~/Projects/FOSS/functional-ruby (test-2-concurrent-ruby-bug)]
$ gem install functional-ruby-1.1.0.test2.gem
Successfully installed functional-ruby-1.1.0.test2
1 gem installed

[07:48:55 Jerry ~/Projects/FOSS/functional-ruby (test-2-concurrent-ruby-bug)]
$ ruby ./test-concurrent-ruby.rb
An exception occurred running ./test-concurrent-ruby.rb:

    Superclass mismatch: Rubinius::AtomicReference != Concurrent::Atomic (TypeError)

Backtrace:

                      Rubinius.open_class_under at kernel/delta/rubinius.rb:334
                            Rubinius.open_class at kernel/delta/rubinius.rb:24
                             Object#__script__ at /Users/Jerry/.rvm/gems/rbx-2.2.10@test/gems/concurrent-ruby-0.7.0.rc2-x86_64-darwin-13/lib/concurrent/atomic.rb:83
                   Rubinius::CodeLoader.require at kernel/common/code_loader.rb:243
  Kernel(Object)#gem_original_require (require) at kernel/common/kernel.rb:705
                         Kernel(Object)#require at /Users/Jerry/.rvm/rubies/rbx-2.2.10/library/rubygems/core_ext/kernel_require.rb:55
                             Object#__script__ at /Users/Jerry/.rvm/gems/rbx-2.2.10@test/gems/concurrent-ruby-0.7.0.rc2-x86_64-darwin-13/lib/concurrent
                                                  /configuration.rb:4
                   Rubinius::CodeLoader.require at kernel/common/code_loader.rb:243
  Kernel(Object)#gem_original_require (require) at kernel/common/kernel.rb:705
                         Kernel(Object)#require at /Users/Jerry/.rvm/rubies/rbx-2.2.10/library/rubygems/core_ext/kernel_require.rb:55
                              Object#__script__ at /Users/Jerry/.rvm/gems/rbx-2.2.10@test/gems/concurrent-ruby-0.7.0.rc2-x86_64-darwin-13/lib/concurrent.rb:3
                   Rubinius::CodeLoader.require at kernel/common/code_loader.rb:243
  Kernel(Object)#gem_original_require (require) at kernel/common/kernel.rb:705
                         Kernel(Object)#require at /Users/Jerry/.rvm/rubies/rbx-2.2.10/library/rubygems/core_ext/kernel_require.rb:55
                              Object#__script__ at /Users/Jerry/.rvm/gems/rbx-2.2.10@test/gems/functional-ruby-1.1.0.test2/lib/functional.rb:27
                   Rubinius::CodeLoader.require at kernel/common/code_loader.rb:243
  Kernel(Object)#gem_original_require (require) at kernel/common/kernel.rb:705
                         Kernel(Object)#require at /Users/Jerry/.rvm/rubies/rbx-2.2.10/library/rubygems/core_ext/kernel_require.rb:135
                              Object#__script__ at test-concurrent-ruby.rb:1
               Rubinius::CodeLoader#load_script at kernel/delta/code_loader.rb:66
               Rubinius::CodeLoader.load_script at kernel/delta/code_loader.rb:152
                        Rubinius::Loader#script at kernel/loader.rb:649
                          Rubinius::Loader#main at kernel/loader.rb:825

