require 'thread'

require 'functional/obligation'
require 'functional/global_thread_pool'

module Functional

  class Future
    include Obligation
    behavior(:future)

    #def cancel
      #return false if @t.nil? || fulfilled?
      #t = Thread.kill(@t)
      #unless t.alive?
        #@value = nil
        #@state = :fulfilled
      #end
      #return ! t.alive?
    #end

    def initialize(*args)

      unless block_given?
        @state = :fulfilled
      else
        @value = nil
        @state = :pending
        #@t = Thread.new do
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
        #@t.abort_on_exception = true
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
