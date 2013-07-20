require 'thread'

module Functional

  class FixedThreadPool

    MIN_POOL_SIZE = 1
    MAX_POOL_SIZE = 1024

    def initialize(size)
      #if size < MIN_POOL_SIZE || size > MAX_POOL_SIZE
        #raise ArgumentError.new("size must be between #{MIN_POOL_SIZE} and #{MAX_POOL_SIZE}")
      #end
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
