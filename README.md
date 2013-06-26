# Functional Ruby [![Build Status](https://secure.travis-ci.org/jdantonio/functional-ruby.png)](http://travis-ci.org/jdantonio/functional-ruby?branch=master) [![Dependency Status](https://gemnasium.com/jdantonio/functional-ruby.png)](https://gemnasium.com/jdantonio/functional-ruby)

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

### Features

* Pattern matching for instance methods.
* Pattern matching for object constructors.
* Parameter count matching
* Matching against primitive values
* Matching by class/datatype
* Matching against specific key/vaue pairs in hashes
* Matching against the presence of keys within hashes
* Implicit hash for last parameter
* Variable-length parameter lists
* Guard clauses
* Recursive calls to other pattern matches
* Recursive calls to superclass pattern matches
* Recursive calls to superclass methods
* Dispatching to superclass methods when no match is found
* Reasonable error messages when no match is found

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

## Erlang-style Pattern Matching

First, familiarize yourself with Erlang [pattern matching](http://learnyousomeerlang.com/syntax-in-functions#pattern-matching).
This gem may not make much sense if you don't understand how Erlang dispatches functions.

In the Ruby class file where you want to use pattern matching, require the *functional-ruby* gem:

```ruby
require 'functional/pattern_matching'
```

Then include `PatternMatching` in your class:

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching

  ...

end
```

You can then define functions with `defn` instead of the normal *def* statement.
The syntax for `defn` is:

```ruby
defn(:symbol_name_of_function, zero, or, more, parameters) { |block, arguments|
  # code to execute
}
```
You can then call your new function just like any other:

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching

  defn(:hello) {
    puts "Hello, World!"
  }
end

foo = Foo.new
foo.hello #=> "Hello, World!"
```

Patterns to match against are included in the parameter list:

```ruby
defn(:greet, :male) {
  puts "Hello, sir!"
}

defn(:greet, :female) {
  puts "Hello, ma'am!"
}

...

foo.hello(:male)   #=> "Hello, sir!"
foo.hello(:female) #=> "Hello, ma'am!"
```

If a particular method call can not be matched a *NoMethodError* is thrown with
a reasonably helpful error message:

```ruby
foo.greet(:unknown) #=> NoMethodError: no method `greet` matching [:unknown] found for class Foo
foo.greet           #=> NoMethodError: no method `greet` matching [] found for class Foo
```

Parameters that are expected to exist but that can take any value are considered
*unbound* parameters. Unbound parameters are specified by the `_` underscore
character or `UNBOUND`:

```ruby
defn(:greet, _) do |name|
  "Hello, #{name}!"
end

defn(:greet, UNBOUND, UNBOUND) do |first, last|
  "Hello, #{first} #{last}!"
end

...

foo.greet('Jerry') #=> "Hello, Jerry!"
```

All unbound parameters will be passed to the block in the order they are specified in the definition:

```ruby
defn(:greet, _, _) do |first, last|
  "Hello, #{first} #{last}!"
end

...

foo.greet('Jerry', "D'Antonio") #=> "Hello, Jerry D'Antonio!"
```

If for some reason you don't care about one or more unbound parameters within
the block you can use the `_` underscore character in the block parameters list
as well:

```ruby
defn(:greet, _, _, _) do |first, _, last|
  "Hello, #{first} #{last}!"
end

...

foo.greet('Jerry', "I'm not going to tell you my middle name!", "D'Antonio") #=> "Hello, Jerry D'Antonio!"
```

Hash parameters can match against specific keys and either bound or unbound parameters. This allows for
function dispatch by hash parameters without having to dig through the hash:

```ruby
defn(:hashable, {foo: :bar}) { |opts|
  :foo_bar
}
defn(:hashable, {foo: _}) { |f|
  f
}

...

foo.hashable({foo: :bar})      #=> :foo_bar
foo.hashable({foo: :baz})      #=> :baz
```

The Ruby idiom of the final parameter being a hash is also supported:

```ruby
defn(:options, _) { |opts|
  opts
}

...

foo.options(bar: :baz, one: 1, many: 2)
```

As is the Ruby idiom of variable-length argument lists. The constant `ALL` as the last parameter
will match one or more arguments and pass them to the block as an array:

```ruby
defn(:baz, Integer, ALL) { |int, args|
  [int, args]
}
defn(:baz, ALL) { |args|
  args
}
```

Superclass polymorphism is supported as well. If an object cannot match a method
signature it will defer to the parent class:

```ruby
class Bar
  def greet
    return 'Hello, World!'
  end
end

class Foo < Bar
  include PatternMatching

  defn(:greet, _) do |name|
    "Hello, #{name}!"
  end
end

...

foo.greet('Jerry') #=> "Hello, Jerry!"
foo.greet          #=> "Hello, World!"
```

Guard clauses in Erlang are defined with `when` clauses between the parameter list and the function body.
In Ruby, guard clauses are defined by chaining a call to `when` onto the the `defn` call and passing
a block. If the guard clause evaluates to true then the function will match. If the guard evaluates
to false the function will not match and pattern matching will continue:

Erlang:

```erlang
old_enough(X) when X >= 16 -> true;
old_enough(_) -> false.
```

Ruby:

```ruby
defn(:old_enough, _){ true }.when{|x| x >= 16 }
defn(:old_enough, _){ false }
```

### Order Matters

As with Erlang, the order of pattern matches is significant. Patterns will be matched
*in the order declared* and the first match will be used. If a particular function call
can be matched by more than one pattern, the *first matched pattern* will be used. It
is the programmer's responsibility to ensure patterns are declared in the correct order.

### Blocks and Procs and Lambdas, oh my!

When using this gem it is critical to remember that `defn` takes a block and
that blocks in Ruby have special rules. There are [plenty](https://www.google.com/search?q=ruby+block+proc+lambda)
of good tutorials on the web explaining [blocks](http://www.robertsosinski.com/2008/12/21/understanding-ruby-blocks-procs-and-lambdas/)
and [Procs](https://coderwall.com/p/_-_mha) and [lambdas](http://railsguru.org/2010/03/learn-ruby-procs-blocks-lambda/)
in Ruby. Please read them. Please don't submit a bug report if you use a
`return` statement within your `defn` and your code blows up with a
[LocalJumpError](http://ruby-doc.org/core-2.0/LocalJumpError.html). 

### Examples

For more examples see the integration tests in *spec/integration_spec.rb*.

#### Simple Functions

This example is based on [Syntax in defnctions: Pattern Matching](http://learnyousomeerlang.com/syntax-in-defnctions) in [Learn You Some Erlang for Great Good!](http://learnyousomeerlang.com/).

Erlang:

```erlang
greet(male, Name) ->
  io:format("Hello, Mr. ~s!", [Name]);
greet(female, Name) ->
  io:format("Hello, Mrs. ~s!", [Name]);
greet(_, Name) ->
  io:format("Hello, ~s!", [Name]).
```

Ruby:

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching

  defn(:greet, _) do |name|
    "Hello, #{name}!"
  end

  defn(:greet, :male, _) { |name|
    "Hello, Mr. #{name}!"
  }
  defn(:greet, :female, _) { |name|
    "Hello, Ms. #{name}!"
  }
  defn(:greet, _, _) { |_, name|
    "Hello, #{name}!"
  }
end
```

#### Simple Functions with Overloading

This example is based on [Syntax in defnctions: Pattern Matching](http://learnyousomeerlang.com/syntax-in-defnctions) in [Learn You Some Erlang for Great Good!](http://learnyousomeerlang.com/).

Erlang:

```erlang
greet(Name) ->
  io:format("Hello, ~s!", [Name]).

greet(male, Name) ->
  io:format("Hello, Mr. ~s!", [Name]);
greet(female, Name) ->
  io:format("Hello, Mrs. ~s!", [Name]);
greet(_, Name) ->
  io:format("Hello, ~s!", [Name]).
```

Ruby:

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching

  defn(:greet, _) do |name|
    "Hello, #{name}!"
  end

  defn(:greet, :male, _) { |name|
    "Hello, Mr. #{name}!"
  }
  defn(:greet, :female, _) { |name|
    "Hello, Ms. #{name}!"
  }
  defn(:greet, nil, _) { |name|
    "Goodbye, #{name}!"
  }
  defn(:greet, _, _) { |_, name|
    "Hello, #{name}!"
  }
end
```

#### Constructor Overloading

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching

  defn(:initialize) { @name = 'baz' }
  defn(:initialize, _) {|name| @name = name.to_s }
end
```

#### Matching by Class/Datatype

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching

  defn(:concat, Integer, Integer) { |first, second|
    first + second
  }
  defn(:concat, Integer, String) { |first, second|
    "#{first} #{second}"
  }
  defn(:concat, String, String) { |first, second|
    first + second
  }
  defn(:concat, Integer, _) { |first, second|
    first + second.to_i
  }
end
```

#### Matching a Hash Parameter

```ruby
require 'functional/pattern_matching'

class Foo
  include PatternMatching
  
  defn(:hashable, {foo: :bar}) { |opts|
    # matches any hash with key :foo and value :bar
    :foo_bar
  }
  defn(:hashable, {foo: _, bar: _}) { |f, b|
    # matches any hash with keys :foo and :bar
    # passes the values associated with those keys to the block
    [f, b]
  }
  defn(:hashable, {foo: _}) { |f|
    # matches any hash with key :foo
    # passes the value associated with that key to the block
    # must appear AFTER the prior match or it will override that one
    f
  }
  defn(:hashable, {}) { ||
    # matches an empty hash
    :empty
  }
  defn(:hashable, _) { |opts|
    # matches any hash (or any other value)
    opts
  }
end

...

foo.hashable({foo: :bar})      #=> :foo_bar
foo.hashable({foo: :baz})      #=> :baz
foo.hashable({foo: 1, bar: 2}) #=> [1, 2] 
foo.hashable({foo: 1, baz: 2}) #=> 1
foo.hashable({bar: :baz})      #=> {bar: :baz}
foo.hashable({})               #=> :empty 
```

#### Variable Length Argument Lists with ALL

```ruby
defn(:all, :one, ALL) { |args|
  args
}
defn(:all, :one, Integer, ALL) { |int, args|
  [int, args]
}
defn(:all, 1, _, ALL) { |var, args|
  [var, args]
}
defn(:all, ALL) { | args|
  args
}

...

foo.all(:one, 'a', 'bee', :see) #=> ['a', 'bee', :see]
foo.all(:one, 1, 'bee', :see)   #=> [1, 'bee', :see]
foo.all(1, 'a', 'bee', :see)    #=> ['a', ['bee', :see]]
foo.all('a', 'bee', :see)       #=> ['a', 'bee', :see]
foo.all()                       #=> NoMethodError: no method `all` matching [] found for class Foo
```

#### Guard Clauses

These examples are based on [Syntax in defnctions: Pattern Matching](http://learnyousomeerlang.com/syntax-in-defnctions)
in [Learn You Some Erlang for Great Good!](http://learnyousomeerlang.com/).

Erlang:

```erlang
old_enough(X) when X >= 16 -> true;
old_enough(_) -> false.

right_age(X) when X >= 16, X =< 104 ->
  true;
right_age(_) ->
  false.

wrong_age(X) when X < 16; X > 104 ->
  true;
wrong_age(_) ->
  false.
```

```ruby
defn(:old_enough, _){ true }.when{|x| x >= 16 }
defn(:old_enough, _){ false }

defn(:right_age, _) {
  true
}.when{|x| x >= 16 && x <= 104 }

defn(:right_age, _) {
  false
}

defn(:wrong_age, _) {
  false
}.when{|x| x < 16 || x > 104 }

defn(:wrong_age, _) {
  true
}
```

## For good -behavior(timeoff).

One of Ruby's greatest strengths is [duck typing](http://rubylearning.com/satishtalim/duck_typing.html).
Usually this is awesome and I'm happy to not have to deal with static typing and the compiler. Usually.
The problem with duck typing is that is is impossible in Ruby to enforce an interface definition.
I would never advocate turning Ruby into the cesspool complex object creation that Java has
unfortunately become, but occasionally it would be nice to make sure a class implements a set of
required methods. Enter Erlang's [-behavior](http://metajack.im/2008/10/29/custom-behaviors-in-erlang/)
keyword. Basically, you define a `behavior_info` then drop a `behavior` call within a class.
Forget to implement a required method and Ruby will let you know. See the examples below for details.

The `behavior` functionality is not imported by default. It needs a separate `require` statement:

```ruby
require 'functional/behavior'

# -or-

require 'functional/behaviour'
```

Next, declare a behavior using the `behavior_info` function (this function should sit outside
of any module/class definition, but will probably work regardless). The first parameter to
`behavior_info` (or `behaviour_info`) is a symbol name for the behavior. The remaining parameter
is a hash of function names and their arity:

```ruby
behaviour_info(:gen_foo, foo: 0, bar: 1, baz: 2)

# -or (for the Java/C# crowd)

interface(:gen_foo, foo: 0, bar: 1, baz: 2)

```

Each function name can be listed only once and the arity must follow the rules of the
[Method#arity](http://ruby-doc.org/core-1.9.3/Method.html#method-i-arity) function.
Though not explicitly documented, block arguments do not count toward a method's arity.
methods defined using this gem's `defn` function will always have an arity of -1,
regardless of how many overloads are defined.

To enforce a behavior on a class simply call the `behavior` function within the class,
passing the name of the desired behavior:

```ruby
class Foo
  behavior(:gen_foo)
  ...
end

# or use the idiomatic Erlang spelling
class Bar
  behaviour(:gen_foo)
  ...
end

# or use the idiomatic Rails syntax
class Baz
  behaves_as :gen_foo
  ...
end
```

Make sure you the implement the required methods in your class. If you don't, Ruby will
raise an exception when you try to create an object from the class:

```ruby
Baz.new #=> ArgumentError: undefined callback functions in Baz (behavior 'gen_foo')
```

As an added bonus, Ruby [Object](http://ruby-doc.org/core-1.9.3/Object.html) will be
monkey-patched with a `behaves_as?` predicate method.

A complete example:

```ruby
behaviour_info(:gen_foo, foo: 0, bar: 1, baz: 2, boom: -1, bam: :any)

class Foo
  behavior(:gen_foo)

  def foo
    return 'foo/0'
  end

  def bar(one, &block)
    return 'bar/1'
  end

  def baz(one, two)
    return 'baz/2'
  end

  def boom(*args)
    return 'boom/-1'
  end

  def bam
    return 'bam!'
  end
end

foo = Foo.new

foo.behaves_as? :gen_foo    #=> true
foo.behaves_as?(:bogus)     #=> false
'foo'.behaves_as? :gen_foo  #=> false
```

## Go, Clojure, and JavaScript-inspired Concurrency

Needs documented...

## Utility Functions

Convenience functions are not imported by default. They need a separate `require` statement:

```ruby
require 'functional/utilities'
```

```ruby
Infinity #=> Infinity
NaN #=> NaN

repl? #=> true when called under irb, pry, bundle console, or rails console

safe(1, 2){|a, b| a + b} #=> 3
safe{ eval 'puts "Hello World!"' } #=> SecurityError: Insecure operation

pp_s [1,2,3,4] #=> "[1, 2, 3, 4]\n" props to Rha7

delta(-1, 1) #=> 2
delta({count: -1}, {count: 1}){|item| item[:count]} #=> 2
```

This gives you access to a few constants and functions:

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
