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

Agents are inspired by Clojure's [agent](http://clojure.org/agents) keyword.
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

score = agent(10)
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
score = Functional::Agent.new(0).
          validate{|value| value <= 1024 }.
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


## Promise


## Thread Pools


### FixedThreadPool



### CachedThreadPool



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
