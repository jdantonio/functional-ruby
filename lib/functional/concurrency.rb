require 'thread'

require 'functional/agent'
require 'functional/future'
require 'functional/promise'

require 'functional/thread_pool'
require 'functional/cached_thread_pool'
require 'functional/fixed_thread_pool'

require 'functional/global_thread_pool'

module Kernel

  # Spawn a single-use thread to run the given block.
  # Supresses exceptions.
  #
  # @param args [Array] zero or more arguments for the block
  # @param block [Proc] operation to be performed concurrently
  #
  # @return [true,false] success/failre of thread creation
  #
  # @note Althought based on Go's goroutines and Erlang's spawn/1,
  # Ruby has a vastly different runtime. Threads aren't nearly as
  # efficient in Ruby. Use this function sparingly.
  #
  # @see http://golang.org/doc/effective_go.html#goroutines
  # @see https://gobyexample.com/goroutines
  def go(*args, &block)
    return false unless block_given?
    $GLOBAL_THREAD_POOL.post(*args, &block)

    #return false unless block_given?
    #t = Thread.new(*args){ |*args|
      #Thread.pass
      #yield(*args)
    #}
    #t.abort_on_exception = false
    #return t.alive?
  end
  module_function :go
end
