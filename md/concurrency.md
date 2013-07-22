# Go, Clojure, and JavaScript-inspired Concurrency

The old-school "lock and synchronize" approach to concurrency is dead. The future of concurrency
is asynchronous. Send out a bunch of independent [actors](http://en.wikipedia.org/wiki/Actor_model)
to do your bidding and process the results when you are ready. Although the idea of the concurrent
actor originated in the early 1970's it has only recently started catching on. Although there is
no one "true" actor implementation (what *exactly* is "object oriented," what *exactly* is
"functional programming"), many modern programming languages implement variations on the actor
theme. This library implements a few of the most interesting and useful of those variations.

Remember, *there is not silver bullet in concurrent programming.* Concurrency is hard. Very hard.
These tools will help ease the burden, but at the end of the day it is essential that you
*know what you are doing.*

## Agent

Agents are inspired by [Clojure's](http://clojure.org/) [agent](http://clojure.org/agents) keyword.
An agent is a single atomic value that represents an identity. The current value
of the agent can be requested at any time (`deref`). Each agent has a work queue and operates on
the global thread pool (see below). Consumers can `post` code blocks to the
agent. The code block (function) will receive the current value of the agent as its sole
parameter. The return value of the block will become the new value of the agent. Agents support
two error handling modes: fail and continue. A good example of an agent is a shared incrementing
counter, such as the score in a video game.

An agent must be initialize with an initial value. This value is always accessible via the `value`
(or `deref`) methods. Code blocks sent to the agent will be processed in the order received. As
each block is processed the current value is updated with the result from the block. This update
is an atomic operation so a `deref` will never block and will always return the current value.

When an agent is created it may be given an optional `validate` block and zero or more `rescue`
blocks. When a new value is calculated the value will be checked against the validator, if present.
If the validator returns `true` the new value will be accepted. If it returns `false` it will be
rejected. If a block raises an exception during execution the list of `rescue` blocks will be
seacrhed in order until one matching the current exception is found. That `rescue` block will
then be called an passed the exception object. If no matching `rescue` block is found, or none
were configured, then the exception will be suppressed.

### Examples

A simple example:

```ruby
require 'functional/agent'
# or
require 'functional/concurrency'

score = Functional::Agent.new(10)
score.value #=> 10

score << proc{|current| current + 100 }
sleep(0.1)
score.value #=> 110

score << proc{|current| current * 2 }
sleep(0.1)
deref score #=> 220

score << proc{|current| current - 50 }
sleep(0.1)
score.value #=> 170
```

With validation and error handling:

```ruby
score = agent(0).validate{|value| value <= 1024 }.
          rescue(NoMethodError){|ex| puts "Bam!" }.
          rescue(ArgumentError){|ex| puts "Pow!" }.
          rescue{|ex| puts "Boom!" }
score.value #=> 0

score << proc{|current| current + 2048 }
sleep(0.1)
score.value #=> 0

score << proc{|current| raise ArgumentError }
sleep(0.1)
#=> puts "Pow!"
score.value #=> 0

score << proc{|current| current + 100 }
sleep(0.1)
score.value #=> 100
```

## Future

Futures are inspired by [Clojure's](http://clojure.org/) [future](http://clojuredocs.org/clojure_core/clojure.core/future) keyword.
A future represents a promise to complete an action at some time in the future. The action is atomic and permanent.
The idea behind a future is to send an action off for asynchronous operation, do other stuff, then return and
retrieve the result of the async operation at a later time. Futures run on the global thread pool (see below).

Futures have three possible states: *pending*, *rejected*, and *fulfilled*. When a future is created it is set
to *pending* and will remain in that state until processing is complete. A completed future is either *rejected*,
indicating that an exception was thrown during processing, or *fulfilled*, indicating succedd. If a future is
*fulfilled* its `value` will be updated to reflect the result of the operation. If *rejected* the `reason` will
be updated with a reference to the thrown exception. The predicate methods `pending?`, `rejected`, and `fulfilled?`
can be called at any time to obtain the state of the future, as can the `state` method, which returns a symbol.

Retrieving the value of a future is done through the `value` (alias: `deref`) method. Obtaining the value of
a future is a potentially blocking operation. When a future is *rejected* a call to `value` will return `nil`
immediately. When a future is *fulfilled* a call to `value` will immediately return the current value.
When a future is *pending* a call to `value` will block until the future is either *rejected* or *fulfilled*.
A *timeout* value can be passed to `value` to limit how long the call will block. If `nil` the call will
block indefinitely. If `0` the call will not block. Any other integer or float value will indicate the
maximum number of seconds to block.

### Examples

A fulfilled example:

```ruby
require 'functional/future'
# or
require 'functional/concurrency'

count = Functional::Future{ sleep(10); 10 }
count.state #=> :pending
count.pending? #=> true

# do stuff...

count.value(0) #=> nil (does not block)

count.value #=> 10 (after blocking)
count.state #=> :fulfilled
count.fulfilled? #=> true
deref count #=> 10
```

A rejected example:

```ruby
count = future{ sleep(10); raise StandardError.new("Boom!") }
count.state #=> :pending
pending?(count) #=> true

deref(count) #=> nil (after blocking)
rejected?(count) #=> true
count.reason #=> #<StandardError: Boom!> 
```

## Promise

A promise is the most powerfule and versatile of the concurrency objects in this library.
Promises are inspired by the JavaScript [Promises/A](http://wiki.commonjs.org/wiki/Promises/A)
and [Promises/A+](http://promises-aplus.github.io/promises-spec/) specifications.

> A promise represents the eventual value returned from the single completion of an operation.

Promises are similar to futures and share many of the same behaviours. Promises are far more robust,
however. Promises can be chained in a tree structure where each promise may have zero or more children.
Promises are chained using the `then` method. The result of a call to `then` is always another promise.
Promises are resolved asynchronously in the order they are added to the tree. Parents are guaranteed
to be resolved before their children. The result of each promise is passed to each of its children
upon resolution. When a promise is rejected all its children will be summarily rejected.

Promises have three possible states: *pending*, *rejected*, and *fulfilled*. When a promise is created it is set
to *pending* and will remain in that state until processing is complete. A completed promise is either *rejected*,
indicating that an exception was thrown during processing, or *fulfilled*, indicating succedd. If a promise is
*fulfilled* its `value` will be updated to reflect the result of the operation. If *rejected* the `reason` will
be updated with a reference to the thrown exception. The predicate methods `pending?`, `rejected`, and `fulfilled?`
can be called at any time to obtain the state of the promise, as can the `state` method, which returns a symbol.

Retrieving the value of a promise is done through the `value` (alias: `deref`) method. Obtaining the value of
a promise is a potentially blocking operation. When a promise is *rejected* a call to `value` will return `nil`
immediately. When a promise is *fulfilled* a call to `value` will immediately return the current value.
When a promise is *pending* a call to `value` will block until the promise is either *rejected* or *fulfilled*.
A *timeout* value can be passed to `value` to limit how long the call will block. If `nil` the call will
block indefinitely. If `0` the call will not block. Any other integer or float value will indicate the
maximum number of seconds to block.

### Examples

A simple example:

```ruby
require 'functional/promise'
# or
require 'functional/concurrency'

p = Functional::Promise.new{ sleep(1); "Hello world!" }
p.value(0) #=> nil (does not block)
p.value #=> "Hello world!" (after blocking)
p.state #=> :fulfilled
```

An example with chaining:

```ruby
p = promise("Jerry", "D'Antonio"){|a, b| "#{a} #{b}" }.
    then{|result| sleep(1); result}.
    then{|result| "Hello #{result}." }.
    then{|result| "#{result} Would you like to play a game?"}

p.pending? #=> true
p.value(0) #=> nil (does not block)

p.value #=> "Hello Jerry D'Antonio. Would you like to play a game?"
```

An example with error handling:

```ruby
@expected = nil
p = promise{ raise ArgumentError }.
  rescue(LoadError){|ex| @expected = 1 }.
  rescue(ArgumentError){|ex| @expected = 2 }.
  rescue(Exception){|ex| @expected = 3 }

sleep(0.1)

@expected     #=> 2
pending?(p)   #=> false
fulfilled?(p) #=> false
rejected?(p)  #=> true

deref(p)      #=> nil
p.reason      #=> #<ArgumentError: ArgumentError>
```

A complex example with chaining and error handling:

```ruby
p = promise("Jerry", "D'Antonio"){|a, b| "#{a} #{b}" }.
    then{|result| sleep(0.5); result}.
    rescue(ArgumentError){|ex| puts "Pow!" }.
    then{|result| "Hello #{result}." }.
    rescue(NoMethodError){|ex| puts "Bam!" }.
    rescue(ArgumentError){|ex| puts "Zap!" }.
    then{|result| raise StandardError.new("Boom!") }.
    rescue{|ex| puts ex.message }.
    then{|result| "#{result} Would you like to play a game?"}

sleep(1)

p.value  #=> nil
p.state  #=> :rejected
p.reason #=> #<StandardError: Boom!>
```

## Goroutine

A goroutine is the simplest of the concurrency utilities in this library. It is inspired by
[Go's](http://golang.org/) [goroutines](https://gobyexample.com/goroutines) and
[Erlang's](http://www.erlang.org/) [spawn](http://erlangexamples.com/tag/spawn/) keyword. The
`go` function is nothing more than a simple way to send a block to the global thread pool (see below)
for processing.

### Examples

```ruby
require 'functional/concurrency'

@expected = nil

go(1, 2, 3){|a, b, c| sleep(1); @expected = [c, b, a] }

sleep(0.1)
@expected #=> nil

sleep(2)
@expected #=> [3, 2, 1]
```

## Thread Pools

### FixedThreadPool

#### Examples

### CachedThreadPool

#### Examples

## Global Thread Pool


### Changing the Global Thread Pool



### EventMachine

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
