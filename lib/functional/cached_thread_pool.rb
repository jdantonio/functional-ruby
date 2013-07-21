require 'thread'

require 'functional/thread_pool'

module Functional

  def self.new_cached_thread_pool
    return FixedThreadPool.new
  end

  class CachedThreadPool
    behavior(:thread_pool)

    def initialize
    end

    def running?
    end

    def shutdown?
    end

    def terminated?
    end

    def shutdown
    end

    def kill
    end

    def size
    end

    def wait_for_termination(timeout = nil)
    end

    def post(*args, &block)
    end

    def <<(block)
    end

    # @private
    def status # :nodoc:
      #@pool.collect{|t| t.status }
    end

  end
end
