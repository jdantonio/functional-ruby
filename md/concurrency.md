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

Agents also implement Ruby's [Observable](http://ruby-doc.org/stdlib-1.9.3/libdoc/observer/rdoc/Observable.html).
Code that observes an agent will receive a callback with the new value any time the value
is changed.

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

With observation:

```ruby
bingo = Class.new{
  def update(time, score)
    puts "Bingo! [score: #{score}, time: #{time}]" if score >= 100
  end
}.new

score = agent(0)
score.add_observer(bingo)

score << proc{|current| sleep(0.1); current += 30 }
score << proc{|current| sleep(0.1); current += 30 }
score << proc{|current| sleep(0.1); current += 30 }
score << proc{|current| sleep(0.1); current += 30 }

sleep(1)
#=> Bingo! [score: 120, time: 2013-07-22 21:26:08 -0400]
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

A promise is the most powerful and versatile of the concurrency objects in this library.
Promises are inspired by the JavaScript [Promises/A](http://wiki.commonjs.org/wiki/Promises/A)
and [Promises/A+](http://promises-aplus.github.io/promises-spec/) specifications.

Promises are more fully described [here](https://github.com/jdantonio/functional-ruby/blob/master/md/promise.md)

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

Thread pools are neither a new idea nor an implementation of the actor pattern. Nevertheless, thread
pools are still an extremely relevant concurrency tool. Every time a thread is created then
subsequently destroyed there is overhead. Creating a pool of reusable worker threads then repeatedly'
dipping into the pool can have huge performace benefits for a long-running application like a service.
Ruby's blocks provide an excellent mechanism for passing a generic work request to a thread, making
Ruby an excellent candidate language for thread pools.

The inspiration for thread pools in this library is Java's `java.util.concurrent` implementation of
[thread pools](java.util.concurrent). The `java.util.concurrent` library is a well-designed, stable,
scalable, and battle-tested concurrency library. It provides three different implementations of thread
pools. One of those implementations is simply a special case of the first and doesn't offer much
advantage in Ruby, so only the first two (`FixedThreadPool` and `CachedThreadPool`) are implemented here.

Thread pools share common `behavior` defined by `:thread_pool`. The most imortant method is `post`
(aliased with the left-shift operator `<<`). The `post` method sends a block to the pool for future
processing.

A running thread pool can be shutdown in an orderly or disruptive manner. Once a thread pool has been
shutdown in cannot be started again. The `shutdown` method can be used to initiate an orderly shutdown
of the thread pool. All new `post` calls will reject the given block and immediately return `false`.
Threads in the pool will continue to process all in-progress work and will process all tasks still in
the queue. The `kill` method can be used to immediately shutdown the pool. All new `post` calls will
reject the given block and immediately return `false`. Ruby's `Thread.kill` will be called on all threads
in the pool, aborting all in-progress work. Tasks in the queue will be discarded.

A client thread can choose to block and wait for pool shutdown to complete. This is useful when shutting
down an application and ensuring the app doesn't exit before pool processing is complete. The method
`wait_for_termination` will block for a maximum of the given number of seconds then return `true` if
shutdown completed successfully or `false`. When the timeout value is `nil` the call will block
indefinitely. Calling `wait_for_termination` on a stopped thread pool will immediately return `true`.

Predicate methods are provided to describe the current state of the thread pool. Provided methods are
`running?`, `shutdown?`, and `killed?`. The `shutdown` method will return true regardless of whether
the pool was shutdown wil `shutdown` or `kill`.

### FixedThreadPool

From the docs:

> Creates a thread pool that reuses a fixed number of threads operating off a shared unbounded queue.
> At any point, at most `nThreads` threads will be active processing tasks. If additional tasks are submitted
> when all threads are active, they will wait in the queue until a thread is available. If any thread terminates
> due to a failure during execution prior to shutdown, a new one will take its place if needed to execute
> subsequent tasks. The threads in the pool will exist until it is explicitly `shutdown`.

#### Examples

```ruby
require 'functional/fixed_thread_pool'
# or
require 'functional/concurrency'

pool = Functional::FixedThreadPool.new(5)

pool.size     #=> 5
pool.running? #=> true
pool.status   #=> ["sleep", "sleep", "sleep", "sleep", "sleep"]

pool.post(1,2,3){|*args| sleep(10) }
pool << proc{ sleep(10) }
pool.size     #=> 5

sleep(11)
pool.status   #=> ["sleep", "sleep", "sleep", "sleep", "sleep"]

pool.shutdown #=> :shuttingdown
pool.status   #=> []
pool.wait_for_termination

pool.size      #=> 0
pool.status    #=> []
pool.shutdown? #=> true
```

### CachedThreadPool

From the docs:

> Creates a thread pool that creates new threads as needed, but will reuse previously constructed threads when
> they are available. These pools will typically improve the performance of programs that execute many short-lived
> asynchronous tasks. Calls to [`post`] will reuse previously constructed threads if available. If no existing
> thread is available, a new thread will be created and added to the pool. Threads that have not been used for
> sixty seconds are terminated and removed from the cache. Thus, a pool that remains idle for long enough will
> not consume any resources. Note that pools with similar properties but different details (for example,
> timeout parameters) may be created using [`CachedThreadPool`] constructors.

#### Examples

```ruby
require 'functional/cached_thread_pool'
# or
require 'functional/concurrency'

pool = Functional::CachedThreadPool.new

pool.size     #=> 0
pool.running? #=> true
pool.status   #=> []

pool.post(1,2,3){|*args| sleep(10) }
pool << proc{ sleep(10) }
pool.size     #=> 2
pool.status   #=> [[:working, nil, "sleep"], [:working, nil, "sleep"]]

sleep(11)
pool.status   #=> [[:idle, 23, "sleep"], [:idle, 23, "sleep"]]

sleep(60)
pool.size     #=> 0
pool.status   #=> []

pool.shutdown #=> :shuttingdown
pool.status   #=> []
pool.wait_for_termination

pool.size      #=> 0
pool.status    #=> []
pool.shutdown? #=> true
```

## Global Thread Pool

For efficiency, of the aforementioned concurrency methods (agents, futures, promises, and
goroutines) run against a global thread pool. This pool can be directly accessed through the
`$GLOBAL_THREAD_POOL` global variable. Generally, this pool should not be directly accessed.
Use the other concurrency features instead.

By default the global thread pool is a `CachedThreadPool`. This means it consumes no resources
unless concurrency functions are called. Most of the time this pool can simply be left alone.

### Changing the Global Thread Pool

It is possible to change the global thread pool. Simply assign a new pool to the `$GLOBAL_THREAD_POOL`
variable:

```ruby
$GLOBAL_THREAD_POOL = Functional::FixedThreadPool.new(10)
```

Ideally this should be done at application startup, before any concurrency functions are called.
If the circumstances warrant the global thread pool can be changed at runtime. Just make sure to
shutdown the old global thread pool so that no tasks are lost:

```ruby
$GLOBAL_THREAD_POOL = Functional::FixedThreadPool.new(10)

# do stuff...

old_global_pool = $GLOBAL_THREAD_POOL
$GLOBAL_THREAD_POOL = Functional::FixedThreadPool.new(10)
old_global_pool.shutdown
```

### EventMachine

The [EventMachine](http://rubyeventmachine.com/) library (source [online](https://github.com/eventmachine/eventmachine))
is an awesome library for creating evented applications. EventMachine provides its own thread pool
and the authors recommend using their pool rather than using Ruby's `Thread`. No sweat,
`functional-ruby` is fully compatible with EventMachine. Simple require `eventmachine`
*before* requiring `functional-ruby` then replace the global thread pool with an instance
of `EventMachineDeferProxy`:

```ruby
require 'eventmachine' # do this FIRST
require 'functional/concurrency'

$GLOBAL_THREAD_POOL = EventMachineDeferProxy.new
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
