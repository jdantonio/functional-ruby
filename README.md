# Functional Ruby
[![Gem Version](https://badge.fury.io/rb/functional-ruby.svg)](http://badge.fury.io/rb/functional-ruby) [![Build Status](https://secure.travis-ci.org/jdantonio/functional-ruby.png)](https://travis-ci.org/jdantonio/functional-ruby?branch=master) [![Coverage Status](https://coveralls.io/repos/jdantonio/functional-ruby/badge.png)](https://coveralls.io/r/jdantonio/functional-ruby) [![Code Climate](https://codeclimate.com/github/jdantonio/functional-ruby.png)](https://codeclimate.com/github/jdantonio/functional-ruby) [![Inline docs](http://inch-ci.org/github/jdantonio/functional-ruby.png)](http://inch-ci.org/github/jdantonio/functional-ruby) [![Dependency Status](https://gemnasium.com/jdantonio/functional-ruby.png)](https://gemnasium.com/jdantonio/functional-ruby)

**A gem for adding functional programming tools to Ruby. Inspired by [Erlang](http://www.erlang.org/),
[Clojure](http://clojure.org/), and [Functional Java](http://functionaljava.org/).**

*NOTE: Version 1.0 is a complete rewrite. Previous versions lacked a unified
focus. Version 1.0 is a cohesive set of utilities inspired by other languages
but designed to work together in ways idiomatic to Ruby.*

Please see the [changelog](https://github.com/jdantonio/functional-ruby/blob/master/CHANGELOG.md) for more information.

## Introduction

Two things I love are [Ruby](http://www.ruby-lang.org/en/) and
[functional](https://en.wikipedia.org/wiki/Functional_programming)
[programming](http://c2.com/cgi/wiki?FunctionalProgramming).
If you combine Ruby's ability to create functions sans-classes with the power
of blocks, `proc`, and `lambda`, Ruby code can follow just about every modern functional
programming design paradigm. Add to this Ruby's vast metaprogramming capabilities
and Ruby is easily one of the most powerful languages in common use today.

### Goals

Our goal is to implement various functional programming patterns in Ruby. Specifically:

* Be an 'unopinionated' toolbox that provides useful utilities without debating which is better or why
* Remain free of external gem dependencies
* Stay true to the spirit of the languages providing inspiration
* But implement in a way that makes sense for Ruby
* Keep the semantics as idiomatic Ruby as possible
* Support features that make sense in Ruby
* Exclude features that don't make sense in Ruby
* Keep everything small
* Be as fast as reasonably possible

## Features

Complete API documentation can be found at [Rubydoc.info](http://rubydoc.info/github/jdantonio/functional-ruby/master/frames).

* Protocol specifications inspired by Clojure [protocol](http://clojure.org/protocols),
  Erlang [behavior](http://www.erlang.org/doc/design_principles/des_princ.html#id60128),
  and Objective-C [protocol](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html)
* Function overloading with Erlang-style [function](http://erlang.org/doc/reference_manual/functions.html)
  [pattern matching](http://erlang.org/doc/reference_manual/patterns.html)
* Simple, immutable data structures, such as *record* and *union*, inspired by
  [Clojure](http://clojure.org/datatypes), [Erlang](http://www.erlang.org/doc/reference_manual/records.html),
  and [others](http://en.wikipedia.org/wiki/Union_type)
* `Either` and `Option` classes based on [Functional Java](http://functionaljava.org/) and [Haskell](https://hackage.haskell.org/package/base-4.2.0.1/docs/Data-Either.html)
* [Memoization](http://en.wikipedia.org/wiki/Memoization) of class methods based on Clojure [memoize](http://clojuredocs.org/clojure_core/clojure.core/memoize)
* Lazy execution with a `Delay` class based on Clojure [delay](http://clojuredocs.org/clojure_core/clojure.core/delay)
* A `final_attribute` variant of Ruby's `attr_accessor` that allows an attribute to be
  written at most once. Based on [Java's `final` keyword](http://en.wikipedia.org/wiki/Final_(Java))

### Supported Ruby Versions

MRI 2.0 and higher, JRuby (1.9 mode), and Rubinius 2.x. This library is pure Ruby and has no gem dependencies.
It should be fully compatible with any interpreter that is compliant with Ruby 2.0 or newer.

### Install

```shell
gem install functional-ruby
```

or add the following line to Gemfile:

```ruby
gem 'functional-ruby'
```

and run `bundle install` from your shell.

Once you've installed the gem you must `require` it in your project:

```ruby
require 'functional'
```

## Examples

Specifying a [protocol](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/Protocol):

```ruby
Functional::SpecifyProtocol(:Name) do
  attr_accessor :first
  attr_accessor :middle
  attr_accessor :last
  attr_accessor :suffix
end
```

Defining immutable [data structures](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/AbstractStruct) including
[Either](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/Either),
[Option](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/Option),
[Union](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/Union) and
[Record](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/Record)

```ruby
Name = Functional::Record.new(:first, :middle, :last, :suffix) do
  mandatory :first, :last
  default :first, 'J.'
  default :last, 'Doe'
end

anon = Name.new #=> #<record Name :first=>"J.", :middle=>nil, :last=>"Doe", :suffix=>nil>
matz = Name.new(first: 'Yukihiro', last: 'Matsumoto') #=> #<record Name :first=>"Yukihiro", :middle=>nil, :last=>"Matsumoto", :suffix=>nil>
```

[Pattern matching](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/PatternMatching)
using [protocols](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/Protocol),
[type](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/TypeCheck) checking,
and other options:

```ruby
class Foo
  include Functional::PatternMatching
  include Functional::Protocol
  include Functional::TypeChecking

  def greet
    return 'Hello, World!'
  end

  defn(:greet, _) do |name|
    "Hello, #{name}!"
  end

  defn(:greet, _) { |name|
    "Pleased to meet you, #{name.fulle_name}!"
  }.when {|name| Type?(CustomerModel, ClientModel) }

  defn(:greet, _) { |name|
    "Hello, #{name.first} #{name.last}!"
  }.when {|name| Satisfy?(:Name) }

  defn(:greet, :doctor, _) { |name|
    "Hello, Dr. #{name}!"
  }

  defn(:greet, nil, _) { |name|
    "Goodbye, #{name}!"
  }

  defn(:greet, _, _) { |_, name|
    "Hello, #{name}!"
  }
end
```

Performance improvement of idempotent functions through [memoization](http://rubydoc.info/github/jdantonio/functional-ruby/master/Functional/Memo):

```ruby
class Factors
  include Functional::Memo

  def self.sum_of(number)
    of(number).reduce(:+)
  end

  def self.of(number)
    (1..number).select {|i| factor?(number, i)}
  end

  def self.factor?(number, potential)
    number % potential == 0
  end

  memoize(:sum_of)
  memoize(:of)
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Copyright

*Functional Ruby* is free software released under the [MIT License](http://www.opensource.org/licenses/MIT).
