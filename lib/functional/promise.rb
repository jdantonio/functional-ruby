# http://promises-aplus.github.io/promises-spec/
# http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/
# http://blog.parse.com/2013/01/29/whats-so-great-about-javascript-promises/

require 'thread'

class Promise

  def then(&block)
    lock do
      tail.next = Promise.new(tail, nil, &block)
      head.thread.run if thread.alive?
    end
    return tail
  end

  def catch(&block)
    @handler = block
    return self
  end

  def initialize(*args, &block)

    if args.first.is_a?(Promise)
      @previous = args.first
      args = args.slice(1, args.length) || []
    end

    @block = block
    process(*args) if @previous.nil?
  end

  protected

  attr_accessor :previous
  attr_accessor :next

  attr_accessor :block
  attr_accessor :handler

  def lock(&block)
    if @mutex.nil?
      head.lock(&block)
    else
      @mutex.synchronize(&block)
    end
  end

  def thread
    @thread || head.thread
  end

  def head
    current = self
    current = current.previous until current.previous.nil?
    return current
  end

  def tail
    current = self
    current = current.next until current.next.nil?
    return current
  end

  def process(*args)
    @mutex = Mutex.new
    @thread = Thread.new(self, *args) do |current, *args|
      Thread.pass
      begin
        result = current.block.call(*args)
        loop do
          if current.next.nil?
            sleep
          else
            current = current.next
            result = fulfill(current, result)
          end
        end
      rescue Exception => ex
        reject(current, ex)
      end
    end
    @thread.abort_on_exception = true
  end

  def fulfill(current, result)
    result = current.block.call(result)
    Thread.pass
    return result
  end

  def reject(current, ex)

    if current.handler.nil?
      current = current.previous until current.handler || current.previous.nil?
    end

    if current.handler
      current.handler.call(ex)
    else
      raise(ex)
    end
  end
end

module Kernel

  def promise(*args, &block)
    return Functional::Promise.new(*args, &block)
  end
  module_function :promise

end
