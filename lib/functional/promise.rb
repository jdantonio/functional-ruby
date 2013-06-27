# http://wiki.commonjs.org/wiki/Promises/A
# http://promises-aplus.github.io/promises-spec/
# http://blog.parse.com/2013/01/29/whats-so-great-about-javascript-promises/
# http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/
# http://www.slideshare.net/domenicdenicola/callbacks-promises-and-coroutines-oh-my-the-evolution-of-asynchronicity-in-javascript

require 'thread'

module Functional

  class Pact
    Oath = Struct.new(:promise, :previous, :next)
  end

  class Promise

    attr_reader :state
    attr_reader :value
    attr_reader :reason

    def fulfilled?() return(@state == :fulfilled); end
    def rejected?() return(@state == :rejected); end
    def pending?() return(!fulfilled? && !rejected?); end

    alias_method :realized?, :fulfilled?
    alias_method :deref, :value

    def initialize(*args, &block)
      if args.first.is_a?(Promise)
        @parent = args.first
      else
        @parent = nil
        @chain = [self]
      end

      @handler = block || Proc.new{}
      @state = :pending
      @value = nil
      @reason = nil
      @children = []

      realize(*args) if @parent.nil?
    end

    def then(&block)
      return self if rejected?
      @children << Promise.new(self, &block)
      push(@children.last)
      root.thread.run if root.thread.alive?
      return @children.last
    end

    def rescue(&block)
      @rescuer = block || Proc.new{}
      return self
    end
    alias_method :catch, :rescue
    alias_method :on_error, :rescue

    protected

    attr_reader :parent
    attr_reader :handler
    attr_reader :rescuer
    attr_reader :thread

    def root
      current = self
      current = current.parent until current.parent.nil?
      return current
    end

    def push(promise)
      if @parent.nil?
        @chain << promise; true
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
      if current.rescuer.nil?
        current = current.previous until current.rescuer || current.previous.nil?
      end
      if current.rescuer
        current.rescuer.call(ex)
      else
        raise(ex)
      end
    end

    def realize(*args)
      @thread = Thread.new(@chain, *args) do |*args|
        result = *args
        current = 0
        loop do
          Thread.pass
          unless @chain[current].rejected?
            begin
              result = @chain[current].handler.call(result)
              @chain[current].on_fulfill(result)
            rescue Exception => ex
              @chain[current].on_reject(ex)
              bubble(@chain[current], ex)
            end
          end
          current += 1
          sleep while current >= @chain.length
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
