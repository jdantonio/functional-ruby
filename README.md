# Functional Ruby
[![Gem Version](https://badge.fury.io/rb/functional-ruby.png)](http://badge.fury.io/rb/functional-ruby) [![Build Status](https://secure.travis-ci.org/jdantonio/functional-ruby.png)](https://travis-ci.org/jdantonio/functional-ruby?branch=master) [![Coverage Status](https://coveralls.io/repos/jdantonio/functional-ruby/badge.png)](https://coveralls.io/r/jdantonio/functional-ruby) [![Code Climate](https://codeclimate.com/github/jdantonio/functional-ruby.png)](https://codeclimate.com/github/jdantonio/functional-ruby) [![Inline docs](http://inch-ci.org/github/jdantonio/functional-ruby.png)](http://inch-ci.org/github/jdantonio/functional-ruby) [![Dependency Status](https://gemnasium.com/jdantonio/functional-ruby.png)](https://gemnasium.com/jdantonio/functional-ruby)

A gem for adding functional programming tools to Ruby. Inspired by [Erlang](http://www.erlang.org/),
[Clojure](http://clojure.org/), and [Functional Java](http://functionaljava.org/).

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

* Protocol specifications inspired by Clojure [protocol](http://clojure.org/protocols)
  and Erlang [behavior](https://github.com/jdantonio/functional-ruby/blob/master/md/behavior.md)
* Function overloading with Erlang-style [Pattern Matching](https://github.com/jdantonio/functional-ruby/blob/master/md/pattern_matching.md)
* Simple, immutable data structures, such as *record* and *union*, inspired by
  [Clojure](http://clojure.org/datatypes), [Erlang](http://www.erlang.org/doc/reference_manual/records.html),
  and [others](http://en.wikipedia.org/wiki/Union_type)
* `Either` and `Option` classes based on [Functional Java](http://functionaljava.org/)

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Copyright

*Functional Ruby* is free software released under the [MIT License](http://www.opensource.org/licenses/MIT).
