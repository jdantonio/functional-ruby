# Functional Ruby
[![Gem Version](https://badge.fury.io/rb/functional-ruby.png)](http://badge.fury.io/rb/functional-ruby) [![Build Status](https://secure.travis-ci.org/jdantonio/functional-ruby.png)](https://travis-ci.org/jdantonio/functional-ruby?branch=master) [![Coverage Status](https://coveralls.io/repos/jdantonio/functional-ruby/badge.png)](https://coveralls.io/r/jdantonio/functional-ruby) [![Code Climate](https://codeclimate.com/github/jdantonio/functional-ruby.png)](https://codeclimate.com/github/jdantonio/functional-ruby) [![Inline docs](http://inch-ci.org/github/jdantonio/functional-ruby.png)](http://inch-ci.org/github/jdantonio/functional-ruby) [![Dependency Status](https://gemnasium.com/jdantonio/functional-ruby.png)](https://gemnasium.com/jdantonio/functional-ruby)

A gem for adding Erlang, Clojure, and Go inspired functional programming tools to Ruby.

## Introduction

Two things I love are [Ruby](http://www.ruby-lang.org/en/) and
[functional](https://en.wikipedia.org/wiki/Functional_programming)
[programming](http://c2.com/cgi/wiki?FunctionalProgramming).
Sadly, the former is generally not associated with the latter. Unfortunately,
too many people are blinded by their belief that Ruby is an object-oriented
language. I reject this assertion. Ruby is certainly object-based, since
everything is an object, but entire large-scale programs can be built without ever
defining a single class. But Ruby's features that support functional programming
don't stop there.

Ask ten different programmers to define the term "functional programming" and
you will likely get ten different answers. One characteristic that will certainly
be on all their lists is support for
[higher](http://en.wikipedia.org/wiki/Higher-order_function)
[order](http://learnyouahaskell.com/higher-order-functions)
[functions](http://learnyousomeerlang.com/higher-order-functions). Put simply, a
higher order function is any function that can take one or more functions as
parameters and/or return a function as a result. Many functional languages,
such as Erlang, Haskell, and Closure, support higher order functions. Higher order
functions are a remarkable tool that can completely change the was software is
designed. Most classicaly object-oriented languages do not support higher
order functions. Unfortunately, Ruby does not directly support higher order
functions. Thanksfully, Ruby *does* give us blocks, `proc`s, and `lambda`s.
Though not strictly higher order functions, in most cases they are functionally
equivalent.

If you combine Ruby's ability to create functions sans-classes with the power
of blocks/`proc`s/`lambda`s, Ruby code can follow just about every modern functional
programming design paradigm. Hence, I consider Ruby to be a *multi-paradigm* language.
Add to this Ruby's vast metaprogramming capabilities and Ruby is easily one of the
most powerful languages in common use today.

This gem is my small and humble attempt to help Ruby reach its full potential as
a highly performant, functional programming language. Virtually every function in
this library takes a block parameter. Some allow a block plus one or more `proc`
arguments. Most operate *on* data structures rather than being buried *in* data
structures. Finally, several of the tools in this library are Ruby implementations
of some of my favorite features from other functional programming languages. Not
every function is pure, but functions with side effects are easy to spot because
they almost always have names that end in an exclamation point.

My hope is that this gem will help Ruby programmers explore Ruby as a functional
language and improve their code in ways our object oriented brethern never
dreamed possible.

### Goals

My goal is to implement various functional programming patterns in Ruby. Specifically:

* Be an 'unopinionated' toolbox that provides useful utilities without debating which is better or why
* Remain free of external gem dependencies
* Stay true to the spirit of the languages providing inspiration
* But implement in a way that makes sense for Ruby
* Keep the semantics as idiomatic Ruby as possible
* Support features that make sense in Ruby
* Exclude features that don't make sense in Ruby
* Keep everything small
* Be as fast as reasonably possible

## Features (and Documentation)

Several features from Erlang, Go, and Clojure have been implemented thus far:

* Interface specifications with Erlang-style [Behavior](https://github.com/jdantonio/functional-ruby/blob/master/md/behavior.md)
* Function overloading with Erlang-style [Pattern Matching](https://github.com/jdantonio/functional-ruby/blob/master/md/pattern_matching.md)

### Supported Ruby versions

MRI 1.9.2, 1.9.3, 2.0, 2.1, and JRuby (1.9 mode). This library is pure Ruby and has no gem dependencies.
It should be fully compatible with any Ruby interpreter that is 1.9.x compliant.

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

### Examples

For complete examples, see the specific documentation linked above. Below are a
few examples to whet your appetite.

#### Pattern Matching (Erlang)

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

#### Behavior (Erlang)

Documentation: [Behavior](https://github.com/jdantonio/functional-ruby/blob/master/md/behavior.md)

```ruby
require 'functional/behavior'

behaviour_info(:gen_foo, foo: 0, self_bar: 1)

class Foo
  behavior(:gen_foo)

  def foo
    return 'foo/0'
  end

  def self.bar(one, &block)
    return 'bar/1'
  end
end

foo = Foo.new

Foo.behaves_as? :gen_foo    #=> true
foo.behaves_as?(:gen_foo)   #=> true
foo.behaves_as?(:bogus)     #=> false
'foo'.behaves_as? :gen_foo  #=> false
```

## Contributors

* [Jerry D'Antonio](https://github.com/jdantonio)
* [404](https://github.com/404pnf)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Copyright

*Functional Ruby* is free software released under the [MIT License](http://www.opensource.org/licenses/MIT).
