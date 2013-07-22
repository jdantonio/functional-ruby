require 'functional/behavior'
require 'functional/event'

behavior_info(:thread_pool,
              running?: 0,
              shutdown?: 0,
              terminated?: 0,
              shutdown: 0,
              kill: 0,
              size: 0,
              wait_for_termination: -1,
              post: -1,
              :<< => 1,
              status: 0)

module Functional

  class ThreadPool

    def initialize
      @status = :running
      @queue = Queue.new
      @termination = Event.new
      @pool = []
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

    def wait_for_termination(timeout = nil)
      if shutdown? || terminated?
        return true
      else
        return @termination.wait(timeout)
      end
    end

    def <<(block)
      self.post(&block)
      return self
    end
  end
end
