require 'thread'

require 'functional/event'

module Functional

  def self.new_fixed_thread_pool(size)
    return FixedThreadPool.new(size)
  end

  class FixedThreadPool

    MIN_POOL_SIZE = 1
    MAX_POOL_SIZE = 1024

    def initialize(size)
      if size < MIN_POOL_SIZE || size > MAX_POOL_SIZE
        raise ArgumentError.new("size must be between #{MIN_POOL_SIZE} and #{MAX_POOL_SIZE}")
      end

      @status = :running
      @queue = Queue.new
      @termination = Event.new

      @pool = size.times.collect{ create_worker_thread }
      collect_garbage
    end

    def running?
      return @status == :running
    end

    def shutdown?
      return ! running?
    end

    def terminated?
      return @status == :terminated
    end

    def shutdown
      @pool.size.times{ @queue << :stop }
      @status = :shuttingdown
    end

    def kill
      @status = :shutdown
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
      if shutdown? || terminated?
        return true
      else
        return @termination.wait(timeout)
      end
    end

    def post(*args, &block)
      raise ArgumentError.new('no block given') unless block_given?
      if running?
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
    def create_worker_thread # :nodoc:
      Thread.new do
        loop do
          task = @queue.pop
          if task == :stop
            break
          else
            task.last.call(*task.first)
          end
        end
        @pool.delete(Thread.current)
        if @pool.empty?
          @termination.set
          @status = :terminated
        end
      end
    end

    # @private
    def collect_garbage # :nodoc:
      @collector = Thread.new do
        sleep(1)
        @pool.size.times do |i|
          if @pool[i].status.nil?
            @pool[i] = create_worker_thread
          end
        end
      end
    end
  end
end
