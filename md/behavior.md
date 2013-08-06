# For good -behavior(timeoff).

One of Ruby's greatest strengths is [duck typing](http://rubylearning.com/satishtalim/duck_typing.html).
Usually this is awesome and I'm happy to not have to deal with static typing and the compiler. Usually.
The problem with duck typing is that is is impossible in Ruby to enforce an interface definition.
I would never advocate turning Ruby into the cesspool complex object creation that Java has
unfortunately become, but occasionally it would be nice to make sure a class implements a set of
required methods. Enter Erlang's [-behavior](http://metajack.im/2008/10/29/custom-behaviors-in-erlang/)
keyword. Basically, you define a `behavior_info` then drop a `behavior` call within a class.
Forget to implement a required method and Ruby will let you know. See the examples below for details.

## Usage

Require the gem

```ruby
require 'functional'
```

### behavior_info

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

To specify class/module methods prepend the methid name with 'self_'

```ruby
behaviour_info(:gen_foo, self_foo: 0, self_bar: 1, baz: 2)
```

### behavior

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

A class may support multiple behaviors:

```ruby
behavior_info(:gen_foo, foo: 0)
behavior_info(:gen_bar, bar: 1)

class FooBar
  behavior(:gen_foo)
  behavior(:gen_bar)
  ...
end
```

Inheritance and module inclusion are supported as well:

```ruby
behavior_info(:gen_foo, foo: 0)
behavior_info(:gen_bar, bar: 0)

class Foo
  behavior(:gen_foo)
  def foo() nil; end
end

module Bar
  behavior(:gen_bar)
  def bar() nil; end
end

class FooBar < Foo
  include Bar
end

foobar = FooBar.new

foobar.behaves_as?(:gen_foo) #=> true
foobar.behaves_as?(:gen_bar) #=> true
```

### behaves_as?

As an added bonus, Ruby [Object](http://ruby-doc.org/core-1.9.3/Object.html) will be
monkey-patched with a `behaves_as?` predicate method.

## Example

A complete example:

```ruby
behaviour_info(:gen_foo, self_foo: 0, bar: 1, baz: 2, boom: -1, bam: :any)

class Foo
  behavior(:gen_foo)

  def self.foo
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

Foo.behaves_as? :gen_foo    #=> true
foo.behaves_as? :gen_foo    #=> true
foo.behaves_as?(:bogus)     #=> false
'foo'.behaves_as? :gen_foo  #=> false
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
