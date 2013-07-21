require 'thread'

module Functional

  class FixedThreadPool

    MIN_POOL_SIZE = 1
    MAX_POOL_SIZE = 1024

    def initialize(size)
      if size < MIN_POOL_SIZE || size > MAX_POOL_SIZE
        raise ArgumentError.new("size must be between #{MIN_POOL_SIZE} and #{MAX_POOL_SIZE}")
      end

      @running = true
      @terminated = false

      @queue = Queue.new

      @pool = size.times.collect do
        Thread.new{ thread_proc }
      end
    end

    def running?
      return @running
    end

    def shutdown?
      return ! running?
    end

    def terminated?
      return @terminated
    end

    def shutdown
      @running = false
      @pool.size.times{ @queue << :stop }
      @terminated = true
    end

    def kill
      @running = false
      @pool.each{|t| Thread.kill(t) }
    end

    def size
      if running?
        return @pool.length
      else
        return 0
      end
    end

    def wait_for_termination(timeout = nil)
    end

    def post(*args, &block)
      raise ArgumentError.new('no block given') unless block_given?
      if @running
        @queue << [args, block]
        return true
      else
        return false
      end
    end

    def <<(block)
      self.post(&block)
    end

    # @private
    def status # :nodoc:
      @pool.collect{|t| t.status }
    end

    private

    # @private
    def thread_proc # :nodoc:
      loop do
        task = @queue.pop
        if task == :stop
          break
        else
          task.last.call(*task.first)
        end
      end
    end

  end
end
