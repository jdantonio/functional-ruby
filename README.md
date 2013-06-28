# Functional Ruby [![Build Status](https://secure.travis-ci.org/jdantonio/functional-ruby.png)](https://travis-ci.org/jdantonio/functional-ruby?branch=master) [![Dependency Status](https://gemnasium.com/jdantonio/functional-ruby.png)](https://gemnasium.com/jdantonio/functional-ruby)

A gem for adding Erlang, Clojure, and Go inspired functional programming tools to Ruby.

The project is hosted on the following sites:

* [RubyGems project page](https://rubygems.org/gems/functional-ruby)
* [Source code on GitHub](https://github.com/jdantonio/functional-ruby)
* [YARD documentation on RubyDoc.org](http://rubydoc.info/github/jdantonio/functional-ruby/)
* [Continuous integration on Travis-CI](https://travis-ci.org/jdantonio/functional-ruby)
* [Dependency tracking on Gemnasium](https://gemnasium.com/jdantonio/functional-ruby)
* [Follow me on Twitter](https://twitter.com/jerrydantonio)

## Introduction

[Ruby](http://www.ruby-lang.org/en/) is my favorite programming by far. As much as I love
Ruby I've always been a little disappointed that Ruby doesn't support function overloading.
Function overloading tends to reduce branching and keep function signatures simpler.
No sweat, I learned to do without. Then I started programming in [Erlang](http://www.erlang.org/)...

I've really started to enjoy working in Erlang. Erlang is good at all the things Ruby is bad
at and vice versa. Together, Ruby and Erlang make me happy. My favorite Erlang feature is,
without question, [pattern matching](http://learnyousomeerlang.com/syntax-in-functions#pattern-matching).
Pattern matching is like function overloading cranked to 11. So one day I was musing on Twitter
that I'd like to see Erlang-stype pattern matching in Ruby and one of my friends responded "Build it!"
So I did. And here it is.

For fun I threw in Erlang's sparsely documented [-behaviour](http://www.erlang.org/doc/design_principles/gen_server_concepts.html)
functionality plus a few other functions and constants I find useful. Eventually I realized I was
building something much more than just Erlang's pattern matching. I was creating a broader library
for helping programmers write Ruby code in a functional style. So I changed the name of the gem
and kept on trucking.

### Goals

* Stay true to the spirit of the languages providing inspiration
* But implement in a way that makes sense for Ruby
* Keep the semantics as idiomatic Ruby as possible
* Support features that make sense in Ruby
* Exclude features that only make sense in Erlang
* Keep everything small
* Be as fast as reasonably possible

## Features

* Function overloading with Erlang-style [Pattern Matching](http://rubydoc.info/github/jdantonio/functional-ruby/master/file/md/pattern_matching.md)
* Interface specifications with Erlang-style [Behavior](http://rubydoc.info/github/jdantonio/functional-ruby/master/file/md/behavior.md)
* Chained asynchronous operations inspried by JavaScript [Promises](http://rubydoc.info/github/jdantonio/functional-ruby/master/file/md/promise.md)
* Additional Clojure, Go, and Erlang inspired [Concurrency](http://rubydoc.info/github/jdantonio/functional-ruby/master/file/md/concurrency.md)
* Several useful functional [Utilities](http://rubydoc.info/github/jdantonio/functional-ruby/master/file/md/utilities.md)

## Supported Ruby versions

MRI 1.9.x and above. Anything else and your mileage may vary.

## Install

```shell
gem install functional-ruby
```

or add the following line to Gemfile:

```ruby
gem 'functional-ruby'
```

and run `bundle install` from your shell.

Once you've installed the gem you must `require` it in your project. Becuase this gem includes multiple features
that not all users may want, several `require` options are available:

```ruby
require 'functional/behavior'
require 'functional/behaviour' # alternate spelling
require 'functional/concurrency'
require 'functional/pattern_matching'
require 'functional/promise'
require 'functional/utilities'
```

If you want everything you can do that, too:

```ruby
require 'functional/all'
```

## Copyright

*Functional Ruby* is Copyright &copy; 2013 [Jerry D'Antonio](https://twitter.com/jerrydantonio).
It is free software and may be redistributed under the terms specified in the LICENSE file.

## License

Released under the MIT license.

http://www.opensource.org/licenses/mit-license.php  

> Permission is hereby granted, free of charge, to any person obtaining a copy  
> of this software and associated documentation files (the "Software"), to deal  
> in the Software without restriction, including without limitation the rights  
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
> copies of the Software, and to permit persons to whom the Software is  
> furnished to do so, subject to the following conditions:  
> 
> The above copyright notice and this permission notice shall be included in  
> all copies or substantial portions of the Software.  
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  
> THE SOFTWARE.  
