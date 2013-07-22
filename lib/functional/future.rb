require 'thread'

require 'functional/obligation'
require 'functional/global_thread_pool'

module Functional

  class Future
    include Obligation
    behavior(:future)

    def initialize(*args)

      unless block_given?
        @state = :fulfilled
      else
        @value = nil
        @state = :pending
        $GLOBAL_THREAD_POOL.post do
          semaphore.synchronize do
            Thread.pass
            begin
              @value = yield(*args)
              @state = :fulfilled
            rescue Exception => ex
              @state = :rejected
              @reason = ex
            end
          end
        end
      end
    end
  end
end

module Kernel

  def future(*args, &block)
    return Functional::Future.new(*args, &block)
  end
  module_function :future
end
