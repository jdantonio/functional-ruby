require 'thread'

module Functional

  class Promise

    def initialize(*args, &block)
      raise ArgumentError.new('no block given') unless block_given?

      @lock = Mutex.new
      @promises = [ [block, nil] ]

      @t = Thread.new do
        Thread.pass # defer to caller
        index = 1

        begin
          # call first promise
          result = block.call(*args)

          # iterate by index in case more promises are added
          while index < @promises.length do
            Thread.pass # defer to caller

            @lock.synchronize do
              # call the next promise
              result = @promises[index].first.call(result)
              index += 1
            end
          end

        rescue Exception => e
          resolved = @lock.synchronize do

            # reverse iterate looking for an error block
            index.step(0, -1) do |i|

              # process the first error handler
              unless @promises[i].last.nil?
                @promises[i].last.call(e)
                break(true)
              end
            end
          end

          # if no error handler found, raise the exception again
          raise(e) unless resolved === true
        end
      end

      @t.abort_on_exception = false
    end

    def then(&block)
      raise ArgumentError.new('no block given') unless block_given?
      @lock.synchronize do
        @promises << [block, nil]
      end
      return self
    end

    def error(&block)
      raise ArgumentError.new('no block given') unless block_given?
      @lock.synchronize do
        @promises.last[1] = block
      end
      return self
    end
  end

  # p = Process.new{|receive| 'Bam!' }
  # # -or-
  # p = make {|receive| 'Bam!' }

  # p << 'Boom!' # send the message 'Boom!' to the process
  # x = nil
  # p >> x # retrieve the next message from the process

  # p.kill # stop the process and freeze it
  
  # http://www.ruby-doc.org/core-1.9.3/ObjectSpace.html
  class Process

    def initialize(&block)
      raise ArgumentError.new('no block given') unless block_given?
      ObjectSpace.define_finalizer(self, proc {|id| puts "Finalizer one on #{id}" })
    end

    def <<(send)
    end

    def >>(receive)
    end
  end
end

module Kernel

  private

  def go(*args, &block)
    raise ArgumentError.new('no block given') unless block_given?
    t = Thread.new(*args){ |*args|
      Thread.pass
      self.instance_exec(*args, &block)
    }
    t.abort_on_exception = false
    return t.alive?
  end
  module_function :go

  def promise(*args, &block)
    return Functional::Promise.new(*args, &block)
  end
  module_function :promise

  # called `spawn` in Erlang, but Ruby already has a spawn function
  # called `make` in Go
  def make(&block)
    return Functional::Process.new(&block)
  end
  module_function :spawn

end
