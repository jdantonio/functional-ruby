require 'thread'
require 'timeout'

require 'functional/concurrent_behavior'

module Functional

  class Future
    behavior(:future)

    attr_reader :state

    # Has the promise been fulfilled?
    # @return [Boolean]
    def fulfilled?() return(@state == :fulfilled); end

    # Is promise completion still pending?
    # @return [Boolean]
    def pending?() return(! fulfilled?); end

    def value(timeout = nil)
      if @mutex.nil? || fulfilled?
        return @value
      elsif timeout.nil?
        return @mutex.synchronize { @value }
      else
        begin
          return Timeout::timeout(timeout.to_f) {
            @mutex.synchronize { @value }
          }
        rescue Timeout::Error => ex
          return nil
        end
      end
    end

    def cancel
      return false if @t.nil? || fulfilled?
      t = Thread.kill(@t)
      unless t.alive?
        @value = nil
        @state = :fulfilled
      end
      return ! t.alive?
    end

    alias_method :realized?, :fulfilled?
    alias_method :deref, :value

    def initialize(*args)

      unless block_given?
        @state = :fulfilled
      else
        @state = :pending
        @mutex = Mutex.new
        @t = Thread.new do
          @mutex.synchronize do
            Thread.pass
            begin
              @value = yield(*args)
            rescue Exception => ex
              # supress
            end
            @state = :fulfilled
          end
          @mutex = nil
        end
        @t.abort_on_exception = true
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
