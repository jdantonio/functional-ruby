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
        @waiting.times{ @notifier << :set }
        @waiting = 0
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
        begin
          Timeout::timeout(timeout) do
            @waiting += 1
            @notifier.pop
          end
          return true
        rescue Timeout::Error
          return false
        end
      end
    end
  end
end
