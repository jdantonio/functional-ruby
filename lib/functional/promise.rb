require 'thread'

module Functional

  class Promise

    attr_reader :state
    attr_reader :value
    attr_reader :reason

    def fulfilled?() return(@state == :fulfilled); end
    def rejected?() return(@state == :rejected); end
    def pending?() return(!(fulfilled? || rejected?)); end

    alias_method :realized?, :fulfilled?
    alias_method :deref, :value

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

    def then(&block)
      return self unless pending?
      block = Proc.new{|result| result } unless block_given?
      @children << Promise.new(self, &block)
      push(@children.last)
      root.thread.run if root.thread.alive?
      return @children.last
    end

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

    Rescuer = Struct.new(:clazz, :block)

    def root
      current = self
      current = current.parent until current.root?
      return current
    end

    def root?
      @parent.nil?
    end

    def push(promise)
      if root?
        @mutex.synchronize {
          @chain << promise
        }
      else
        @parent.push(promise)
      end
    end

    def on_fulfill(value)
      @state = :fulfilled
      @value = value
      @reason = nil
      self.freeze
    end

    def on_reject(reason)
      @state = :rejected
      @reason = reason.is_a?(Exception) ? reason.inspect : reason.to_s
      @value = nil
      @children.each{|child| child.on_reject(reason)}
      self.freeze
    end

    def bubble(current, ex)
      rescuer = until current.nil?
                  match = current.rescuers.find{|r| ex.is_a?(r.clazz) }
                  break(match) unless match.nil?
                  current = current.parent
                end
      rescuer.block.call(ex) if rescuer
    end

    def realize(*args)
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

  def promise(*args, &block)
    return Functional::Promise.new(*args, &block)
  end
  module_function :promise
end
