require 'thread'

module Functional

  class CachedThreadPool

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

  end
end
