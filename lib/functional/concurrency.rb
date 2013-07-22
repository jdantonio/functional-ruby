require 'thread'

require 'functional/agent'
require 'functional/future'
require 'functional/promise'

require 'functional/thread_pool'
require 'functional/cached_thread_pool'
require 'functional/fixed_thread_pool'

require 'functional/global_thread_pool'

require 'functional/event_machine_defer_proxy' if defined?(EventMachine)

module Kernel

  # Post the given agruments and block to the Global Thread Pool.
  #
  # @param args [Array] zero or more arguments for the block
  # @param block [Proc] operation to be performed concurrently
  #
  # @return [true,false] success/failre of thread creation
  #
  # @note Althought based on Go's goroutines and Erlang's spawn/1,
  # Ruby has a vastly different runtime. Threads aren't nearly as
  # efficient in Ruby. Use this function appropriately.
  #
  # @see http://golang.org/doc/effective_go.html#goroutines
  # @see https://gobyexample.com/goroutines
  def go(*args, &block)
    return false unless block_given?
    $GLOBAL_THREAD_POOL.post(*args, &block)
  end
  module_function :go
end
