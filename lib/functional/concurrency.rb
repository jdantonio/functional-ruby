require 'functional/promise'

module Functional

  # p = Process.new{|receive| 'Bam!' }
  # # -or-
  # p = make {|receive| 'Bam!' }

  # p << 'Boom!' # send the message 'Boom!' to the process
  # x = nil
  # p >> x # retrieve the next message from the process

  # p.kill # stop the process and freeze it

  # http://www.ruby-doc.org/core-1.9.3/ObjectSpace.html
  #class Process

    #def initialize(&block)
      #raise ArgumentError.new('no block given') unless block_given?
      #ObjectSpace.define_finalizer(self, proc {|id| puts "Finalizer one on #{id}" })
    #end

    #def <<(send)
    #end

    #def >>(receive)
    #end
  #end
end

module Kernel

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

  # called `spawn` in Erlang, but Ruby already has a spawn function
  # called `make` in Go
  def make(&block)
    return Functional::Process.new(&block)
  end
  module_function :make

end
