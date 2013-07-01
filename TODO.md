# To-do

These are ideas I have for additional functionality. Some may actually get implemented.

## Concurrency

Erlang/Go send-receive/channel: Built on their lightweight processes mechanisms, both
Erlang and Go support message passing send/receive loops between processes. The heavyweight
threads in Ruby make long-lived send/receive loops compelling.

## Enums

* http://docs.oracle.com/javase/tutorial/java/javaOO/enum.html
* http://www.lesismore.co.za/rubyenums.html
* http://gistflow.com/posts/682-ruby-enums-approaches

## Clojure

http://richhickey.github.io/clojure/clojure.core-api.html

### Core

* [apply](http://clojuredocs.org/clojure_core/clojure.core/apply)
* [delay](http://clojuredocs.org/clojure_core/clojure.core/delay)
* [await](http://clojuredocs.org/clojure_core/clojure.core/await)
* [memoize](http://clojuredocs.org/clojure_core/clojure.core/memoize)

## Other stuff

* retry - retries something x times if it fails
* ada range type - http://en.wikibooks.org/wiki/Ada_Programming/Types/range

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
