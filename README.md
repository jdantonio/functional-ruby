# Functional Ruby [![Build Status](https://secure.travis-ci.org/jdantonio/functional-ruby.png)](https://travis-ci.org/jdantonio/functional-ruby?branch=master) [![Dependency Status](https://gemnasium.com/jdantonio/functional-ruby.png)](https://gemnasium.com/jdantonio/functional-ruby)

A gem for adding Erlang, Clojure, and Go inspired functional programming tools to Ruby.

The project is hosted on the following sites:

* [RubyGems project page](https://rubygems.org/gems/functional-ruby)
* [Source code on GitHub](https://github.com/jdantonio/functional-ruby)
* [YARD documentation on RubyDoc.info](http://rubydoc.info/github/jdantonio/functional-ruby/master/frames)
* [Continuous integration on Travis-CI](https://travis-ci.org/jdantonio/functional-ruby)
* [Dependency tracking on Gemnasium](https://gemnasium.com/jdantonio/functional-ruby)
* [Follow me on Twitter](https://twitter.com/jerrydantonio)

## Introduction

Three things I love are [Ruby](http://www.ruby-lang.org/en/),
[functional](https://en.wikipedia.org/wiki/Functional_programming)
[programming](http://c2.com/cgi/wiki?FunctionalProgramming) and
[concurrency](http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Dstripbooks&field-keywords=concurrent%20programming).
Sadly, the first is generally not associated with the other two. First, I reject the
assertion that Ruby is an object-oriented language. It's certainly object-based, since
everything is an object, but entire large-scale programs can be built without ever
defining a single class. Ruby is a true multi-paradigm language and easily supports
many advanced functional techniques. As to concurrency, Ruby's bad reputation is
well earned, but recent versions of Ruby have made significan improvements in that
area. Ruby 2.0 is now a [relevant](https://blog.heroku.com/archives/2013/6/17/ruby-2-default-new-aps)
platform for concurrent applications.

This gem is my small and humble attempt to help Ruby reach its full potential as
a highly performant, functional, concurrent programming language.

### Goals

My history with high-performance, highly-concurrent programming goes back to my days with C/C++.
I have the same scars as everyone else doing that kind of work with those languages.
I'm fascinated by modern concurrency patterns like [Actors](http://en.wikipedia.org/wiki/Actor_model),
[Agents](http://doc.akka.io/docs/akka/snapshot/java/agents.html), and
[Promises](http://promises-aplus.github.io/promises-spec/). I'm equally fascinated by languages
with strong concurrency support like [Erlang](http://www.erlang.org/doc/getting_started/conc_prog.html),
[Go](http://golang.org/doc/articles/concurrency_patterns.html), and
[Clojure](http://clojure.org/concurrent_programming) (I program with Erlang at work).
My goal is to implement those patterns in Ruby. Specifically:

* Stay true to the spirit of the languages providing inspiration
* But implement in a way that makes sense for Ruby
* Keep the semantics as idiomatic Ruby as possible
* Support features that make sense in Ruby
* Exclude features that don't make sense in Ruby
* Keep everything small
* Be as fast as reasonably possible

## Features

Several features from Erlang, Co, Clojure, and JavaScript have been implemented this far:

* Function overloading with Erlang-style [Pattern Matching](https://github.com/jdantonio/functional-ruby/blob/master/md/pattern_matching.md)
* Interface specifications with Erlang-style [Behavior](https://github.com/jdantonio/functional-ruby/blob/master/md/behavior.md)
* Chained asynchronous operations inspried by JavaScript [Promises](https://github.com/jdantonio/functional-ruby/blob/master/md/promise.md)
* Additional Clojure, Go, and Erlang inspired [Concurrency](https://github.com/jdantonio/functional-ruby/blob/master/md/concurrency.md)
* Several useful functional [Utilities](https://github.com/jdantonio/functional-ruby/blob/master/md/utilities.md)

### Supported Ruby versions

MRI 1.9.2, 1.9.3, and 2.0. Anything else and your mileage may vary.
Althought I do test under Rubinius and JRuby in 1.9 mode I'll drop them if they become problematic.)

### Install

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

## Examples

For complete examples, see the specific documentation linked above. Below are a
few examples to whet your appetite.

### Pattern Matching (Erlang)

Documentation: [Pattern Matching](https://github.com/jdantonio/functional-ruby/blob/master/md/pattern_matching.md)

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching

  defn(:greet, :male) {
    puts "Hello, sir!"
  }

  defn(:greet, :female) {
    puts "Hello, ma'am!"
  }
end

foo = Foo.new
foo.greet(:male)   #=> "Hello, sir!"
foo.greet(:female) #=> "Hello, ma'am!"
```

### Behavior (Erlang)

Documentation: [Behavior](https://github.com/jdantonio/functional-ruby/blob/master/md/behavior.md)

```ruby
require 'functional/behavior'

behaviour_info(:gen_foo, foo: 0, bar: 1)

class Foo
  behavior(:gen_foo)

  def foo
    return 'foo/0'
  end

  def bar(one, &block)
    return 'bar/1'
  end
end

foo = Foo.new

foo.behaves_as? :gen_foo    #=> true
foo.behaves_as?(:bogus)     #=> false
'foo'.behaves_as? :gen_foo  #=> false
```

### Promises (JavaScript)

Documentation: [Promises](https://github.com/jdantonio/functional-ruby/blob/master/md/promise.md)

```ruby
require 'functional/promise'

p = promise("Jerry", "D'Antonio"){|a, b| "#{a} #{b}" }.
    then{|result| "Hello #{result}." }.
    rescue(StandardError){|ex| puts "Boom!" }.
    then{|result| "#{result} Would you like to play a game?"}
sleep(1)
p.value #=> "Hello Jerry D'Antonio. Would you like to play a game?" 

```

### Utilities

Documentation: [Utilities](https://github.com/jdantonio/functional-ruby/blob/master/md/utilities.md)

```ruby
Infinity #=> Infinity
NaN #=> NaN

repl? #=> true when called under irb, pry, bundle console, or rails console

safe(1, 2){|a, b| a + b} #=> 3
safe{ eval 'puts "Hello World!"' } #=> SecurityError: Insecure operation

pp_s [1,2,3,4] #=> "[1, 2, 3, 4]\n" props to Rha7

delta(-1, 1) #=> 2
delta({count: -1}, {count: 1}){|item| item[:count]} #=> 2

# And many more!
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
