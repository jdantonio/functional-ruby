require 'thread'

module Functional

  class Promise

    attr_reader :state
    attr_reader :value
    attr_reader :reason

    # Has the promise been fulfilled?
    # @return [Boolean]
    def fulfilled?() return(@state == :fulfilled); end

    # Has the promise been rejected?
    # @return [Boolean]
    def rejected?() return(@state == :rejected); end

    # Is promise completion still pending?
    # @return [Boolean]
    def pending?() return(!(fulfilled? || rejected?)); end

    alias_method :realized?, :fulfilled?
    alias_method :deref, :value

    # Creates a new promise object. "A promise represents the eventual
    # value returned from the single completion of an operation."
    # Promises can be chained in a tree structure where each promise
    # has zero or more children. Promises are resolved asynchronously
    # in the order they are added to the tree. Parents are guaranteed
    # to be resolved before their children. The result of each promise
    # is passes to each of its children when the child resolves. When
    # a promise is rejected all its children will be summarily rejected.
    # A promise that is neither resolved or rejected is pending.
    #
    # @param args [Array] zero or more arguments for the block
    # @param block [Proc] the block to call when attempting fulfillment
    #
    # @see http://wiki.commonjs.org/wiki/Promises/A
    def initialize(*args, &block)
      if args.first.is_a?(Promise)
        @parent = args.first
      else
        @parent = nil
        @chain = [self]
        @mutex = Mutex.new
      end

      @handler = block || Proc.new{|result| result }
      @state = :pending
      @value = nil
      @reason = nil
      @children = []
      @rescuers = []

      realize(*args) if root?
    end

    # Create a new child Promise. The block argument for the child will
    # be the result of fulfilling its parent.
    #
    # @param block [Proc] the block to call when attempting fulfillment
    #
    # @return [Promise] the new promise
    def then(&block)
      return self unless pending?
      block = Proc.new{|result| result } unless block_given?
      @children << Promise.new(self, &block)
      push(@children.last)
      root.thread.run if root.thread.alive?
      return @children.last
    end

    # Add a rescue block to be run if the promise is rejected (via raised
    # exception). Multiple rescue blocks may be added to a Promise.
    # Rescue blocks will be checked in order and the first one with a
    # matching Exception class will be processed. The block argument
    # will be the exception that caused the rejection.
    #
    # @param clazz [Class] The class of exception to rescue
    # @param block [Proc] the block to call if the rescue is matched
    #
    # @return [self] so that additional chaining can occur
    def rescue(clazz = Exception, &block)
      @rescuers << Rescuer.new(clazz, block) if block_given?
      return self
    end
    alias_method :catch, :rescue
    alias_method :on_error, :rescue

    protected

    attr_reader :parent
    attr_reader :handler
    attr_reader :rescuers
    attr_reader :thread

    # @private
    Rescuer = Struct.new(:clazz, :block)

    # @private
    def root # :nodoc:
      current = self
      current = current.parent until current.root?
      return current
    end

    # @private
    def root? # :nodoc:
      @parent.nil?
    end

    # @private
    def push(promise) # :nodoc:
      if root?
        @mutex.synchronize {
          @chain << promise
        }
      else
        @parent.push(promise)
      end
    end

    # @private
    def on_fulfill(value) # :nodoc:
      @state = :fulfilled
      @value = value
      @reason = nil
      self.freeze
    end

    # @private
    def on_reject(reason) # :nodoc:
      @state = :rejected
      @reason = reason.is_a?(Exception) ? reason.inspect : reason.to_s
      @value = nil
      @children.each{|child| child.on_reject(reason)}
      self.freeze
    end

    # @private
    def bubble(current, ex) # :nodoc:
      rescuer = until current.nil?
                  match = current.rescuers.find{|r| ex.is_a?(r.clazz) }
                  break(match) unless match.nil?
                  current = current.parent
                end
      rescuer.block.call(ex) if rescuer
    end

    # @private
    def realize(*args) # :nodoc:
      @thread = Thread.new(@chain, @mutex, args) do |chain, mutex, args|
        result = args.length == 1 ? args.first : args
        index = 0
        loop do
          Thread.pass
          current = mutex.synchronize{ chain[index] }
          unless current.rejected?
            begin
              result = current.handler.call(result)
              current.on_fulfill(result)
            rescue Exception => ex
              current.on_reject(ex)
              bubble(current, ex)
            end
          end
          index += 1
          sleep while index >= chain.length
        end
      end
      @thread.abort_on_exception = true
    end
  end
end

module Kernel

  # Creates a new promise object. "A promise represents the eventual
  # value returned from the single completion of an operation."
  # Promises can be chained in a tree structure where each promise
  # has zero or more children. Promises are resolved asynchronously
  # in the order they are added to the tree. Parents are guaranteed
  # to be resolved before their children. The result of each promise
  # is passes to each of its children when the child resolves. When
  # a promise is rejected all its children will be summarily rejected.
  # A promise that is neither resolved or rejected is pending.
  #
  # @param args [Array] zero or more arguments for the block
  # @param block [Proc] the block to call when attempting fulfillment
  #
  # @see Promise
  # @see http://wiki.commonjs.org/wiki/Promises/A
  def promise(*args, &block)
    return Functional::Promise.new(*args, &block)
  end
  module_function :promise
end
