require 'observer'
require 'thread'

module Functional

  # An agent is a single atomic value that represents an identity. The current value
  # of the agent can be requested at any time (#deref). Each agent has a work queue and operates on
  # its own thread (or a thread from the shared pool). Consumers can #send code blocks to the
  # agent. The code block (function) will receive the current value of the agent as its sole
  # parameter. The return value of the block will become the new value of the agent. Agents support
  # two error handling modes: fail and continue. A good example of an agent is a shared incrementing
  # counter.
  class Agent
    include Observable

    TIMEOUT = 5

    attr_reader :value
    attr_reader :initial
    attr_reader :timeout

    def initialize(initial, timeout = TIMEOUT)
      @value = initial
      @timeout = timeout
      @rescuers = []
      @validator = nil
      @queue = Queue.new

      @thread = Thread.new{ work }
      @thread.abort_on_exception = true
    end

    def rescue(clazz = Exception, &block)
      @rescuers << Rescuer.new(clazz, block) if block_given?
      return self
    end
    alias_method :catch, :rescue
    alias_method :on_error, :rescue

    def validate(&block)
      @validator = block if block_given?
      return self
    end
    alias_method :validates, :validate
    alias_method :validate_with, :validate
    alias_method :validates_with, :validate

    def send(&block)
      return @queue.length unless block_given?
      @queue << block
      return @queue.length
    end
    def <<(block)
      send(&block)
    end

    def length
      @queue.length
    end
    alias_method :size, :length
    alias_method :count, :length

    alias_method :deref, :value
    alias_method :add_watch, :add_observer

    private

    # @private
    Rescuer = Struct.new(:clazz, :block)

    # @private
    def try_rescue(ex) # :nodoc:
      rescuer = @rescuers.find{|r| ex.is_a?(r.clazz) }
      rescuer.block.call(ex) if rescuer
    rescue Exception => e
      # supress
    end

    # @private
    def work # :nodoc:
      loop do
        Thread.pass
        handler = @queue.pop
        begin
          result = Timeout.timeout(@timeout){
            handler.call(@value)
          }
          if @validator.nil? || @validator.call(result)
            @value = result
            changed
            notify_observers(Time.now, @value)
          end
        rescue Exception => ex
          try_rescue(ex)
        end
      end
    end
  end
end

module Kernel

  def agent(initial, timeout = Functional::Agent::TIMEOUT)
    return Functional::Agent.new(initial, timeout)
  end
  module_function :agent
end
