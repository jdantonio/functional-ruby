require 'thread'
require 'timeout'

module Functional

  class Event

    def initialize
      @set = false
      @notifier = Queue.new
      @mutex = Mutex.new
      @waiting = 0
    end

    def set?
      return @set == true
    end

    def set
      return true if set?
      @mutex.synchronize {
        @set = true
        while @waiting > 0
          @notifier << :set
          @waiting -= 1
        end
      }
    end

    def reset
      @mutex.synchronize {
        @set = false
      }
    end

    def wait(timeout = nil)
      return true if set?

      if timeout.nil?
        @waiting += 1
        @notifier.pop
      else
        Timeout::timeout(timeout) do
          @waiting += 1
          @notifier.pop
        end
      end
      return true
    rescue Timeout::Error
      return false
    end
  end
end
