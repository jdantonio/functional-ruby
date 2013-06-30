# To-do

These are ideas I have for additional functionality. Some may actually get implemented.

## Concurrency

* http://stackoverflow.com/questions/1028250/what-is-functional-reactive-programming/1030631#1030631

Clojure agent: An agent is a single atomic value that represents an identity. The current value
of the agent can be requested at any time (#deref). Each agent has a work queue and operates on
its own thread (or a thread from the shared pool). Consumers can #send code blocks to the
agent. The code block (function) will receive the current value of the agent as its sole
parameter. The return value of the block will become the new value of the agent. Agents support
two error handling modes: fail and continue. A good example of an agent is a shared incrementing
counter.

Erlang process/Go goroutine: Erlang and Go have very lightweight concurrency mechanisms
(processes and goroutines respectively). A process can be launched at any time and given
a function. It will run the function concurrently then die. The return value will not
go anywhere so side-effects are necessary. Ruby threads are not nearly as lightweight
as Erlang/Go processes, but used sparingly the simplicity of the model is appealing.

Erlang/Go send-receive/channel: Built on their lightweight processes mechanisms, both
Erlang and Go support message passing send/receive loops between processes. The heavyweight
threads in Ruby make long-lived send/receive loops compelling.

Clojure future: At this point, the differences between concurrency tools becomes more subtle.
Clojure futures are very similar to Clojure agents and Go goroutines. A future is simply a
concurrent process that will contain a value once complete. While the future is working
the value cannot be retrieved (and supports blocking deref calls). Once the future is
complete it will forevermore have the finished value. Deref calls at that point do not block

JavaScript promises: A chained series of behavioral routines and associated error handlers.
Excellent for handling a series of actions on a different thread. Promises interact with
the outside world through side-effects.

* http://wiki.commonjs.org/wiki/Promises/A
* http://promises-aplus.github.io/promises-spec/
* http://blog.parse.com/2013/01/29/whats-so-great-about-javascript-promises/
* http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/
* http://www.slideshare.net/domenicdenicola/callbacks-promises-and-coroutines-oh-my-the-evolution-of-asynchronicity-in-javascript

## Enums

* http://docs.oracle.com/javase/tutorial/java/javaOO/enum.html
* http://www.lesismore.co.za/rubyenums.html
* http://gistflow.com/posts/682-ruby-enums-approaches

## Clojure

http://richhickey.github.io/clojure/clojure.core-api.html

### Agents

* [agent](http://clojuredocs.org/clojure_core/clojure.core/agent)
* [set-error-handler!](http://clojuredocs.org/clojure_core/clojure.core/set-error-handler!)
* [restart-agent](http://clojuredocs.org/clojure_core/clojure.core/restart-agent)
* [send](http://clojuredocs.org/clojure_core/clojure.core/send)
* [send-off](http://clojuredocs.org/clojure_core/clojure.core/send-off)
* [agent-error](http://clojuredocs.org/clojure_core/clojure.core/agent-error)
* [release-pending-sends](http://clojuredocs.org/clojure_core/clojure.core/release-pending-sends)
* [add-watch](http://clojuredocs.org/clojure_core/clojure.core/add-watch)
* [set-validator](http://clojuredocs.org/clojure_core/clojure.core/set-validator!)
* [deref](http://clojuredocs.org/clojure_core/clojure.core/deref)

### Futures

* [future](http://clojuredocs.org/clojure_core/clojure.core/future)
* [realized?](http://clojuredocs.org/clojure_core/clojure.core/realized_q)
* [future?](http://clojuredocs.org/clojure_core/clojure.core/future_q)
* [future-cancel](http://clojuredocs.org/clojure_core/clojure.core/future-cancel)
* [deref](http://clojuredocs.org/clojure_core/clojure.core/deref)
* [shutdown-agents](http://clojuredocs.org/clojure_core/clojure.core/shutdown-agents)

### Core

* [apply](http://clojuredocs.org/clojure_core/clojure.core/apply)
* [delay](http://clojuredocs.org/clojure_core/clojure.core/delay)
* [await](http://clojuredocs.org/clojure_core/clojure.core/await)
* [memoize](http://clojuredocs.org/clojure_core/clojure.core/memoize)
* [slurp](http://clojuredocs.org/clojure_core/clojure.core/slurp)

## Other stuff

* retry - retries something x times if it fails
* ada range type - http://en.wikibooks.org/wiki/Ada_Programming/Types/range
* slurpee - slurp + erb parsing

### Using Ruby's queue for sending messages between threads

* http://www.subelsky.com/2010/02/using-rubys-queue-class-to-manage-inter.html
* http://www.ruby-doc.org/stdlib-1.9.3/libdoc/thread/rdoc/Queue.html#method-i-pop

## Code Spikes

```ruby
module Functional
  p = Process.new{|receive| 'Bam!' }
  # -or-
  p = make {|receive| 'Bam!' }

  p << 'Boom!' # send the message 'Boom!' to the process
  x = nil
  p >> x # retrieve the next message from the process

  p.kill # stop the process and freeze it

  http://www.ruby-doc.org/core-1.9.3/ObjectSpace.html
  class Process

    def initialize(&block)
      raise ArgumentError.new('no block given') unless block_given?
      ObjectSpace.define_finalizer(self, proc {|id| puts "Finalizer one on #{id}" })
    end

    def <<(send)
    end

    def >>(receive)
    end
  end
end

module Kernel

  # called `spawn` in Erlang, but Ruby already has a spawn function
  # called `make` in Go
  def make(&block)
    return Functional::Process.new(&block)
  end
  module_function :make
end
```
