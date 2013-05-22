# PatternMatching [![Build Status](https://secure.travis-ci.org/jdantonio/pattern_matching.png)](http://travis-ci.org/jdantonio/pattern_matching?branch=master) [![Dependency Status](https://gemnasium.com/jdantonio/pattern_matching.png)](https://gemnasium.com/jdantonio/pattern_matching)

A gem for adding Erlang-style function/method overloading through pattern matching to Ruby classes.

*NOTE: This is a work in progress. Expect changes.*

The project is hosted on the following sites:

* [RubyGems project page](https://rubygems.org/gems/pattern-matching)
* [Source code on GitHub](https://github.com/jdantonio/pattern_matching)
* [Continuous integration on Travis-CI](https://travis-ci.org/jdantonio/pattern_matching)
* [Dependency tracking on Gemnasium](https://gemnasium.com/jdantonio/pattern_matching)
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

### Goals

* Stay true to the spirit of Erlang pattern matching, if not the semantics
* Keep the semantics as idiomatic Ruby as possible
* Support features that make sense in Ruby
* Exclude features that only make sense in Erlang
* Avoid using *method_missing*
* Keep it small (currently arround 100 LOC)
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

### To-do

* Support class methods
* Support module instance methods
* Support module methods

## Supported Ruby versions

MRI 1.9.x and above. Anything else and your mileage may vary.

## Install

```shell
gem install pattern-matching
```

or add the following line to Gemfile:

```ruby
gem 'pattern-matching'
```

and run `bundle install` from your shell.

## Usage

First, familiarize yourself with Erlang [pattern matching](http://learnyousomeerlang.com/syntax-in-functions#pattern-matching).
This gem may not make much sense if you don't understand how Erlang dispatches
functions.

In the Ruby class file where you want to use pattern matching, require the
*pattern_matching* gem:

```ruby
require 'pattern_matching'
```

Then include `PatternMatching` in your class:

```ruby
require 'pattern_matching'

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
require 'pattern_matching'

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

Hash parameters can match against specific keys and either bound or unbound parameters. This allows for function dispatch by hash parameters without having to dig through the hash:

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

## Examples

For more examples see the integration tests in *spec/integration_spec.rb*.

### Simple Functions

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
require 'pattern_matching'

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

### Simple Functions with Overloading

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
require 'pattern_matching'

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

### Constructor Overloading

```ruby
require 'pattern_matching'

class Foo
  include PatternMatching

  defn(:initialize) { @name = 'baz' }
  defn(:initialize, _) {|name| @name = name.to_s }
end
```

### Matching by Class/Datatype

```ruby
require 'pattern_matching'

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

### Matching a Hash Parameter

```ruby
require 'pattern_matching'

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

### Variable Length Argument Lists with ALL

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

### Guard Clauses

These examples are based on [Syntax in defnctions: Pattern Matching](http://learnyousomeerlang.com/syntax-in-defnctions) in [Learn You Some Erlang for Great Good!](http://learnyousomeerlang.com/).

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

## Copyright

*PatternMatching* is Copyright &copy; 2013 [Jerry D'Antonio](https://twitter.com/jerrydantonio).
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
