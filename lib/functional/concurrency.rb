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

end


#load 'lib/functional/concurrency.rb'

#class Foo
  #def initialize(name = 'World')
    #@name = name
  #end
  #def hello(greeting = 'Hello')
    #go(greeting) do |greet|
      #sleep(rand(5000)/1000.0)
      #puts "#{greet} #{@name}"
    #end 
  #end
  #def boom
    #go { raise StandardError.new("Here comes the BOOM!") }
  #end
#end

#f = Foo.new('Jerry')
#f.hello
#f.hello('Wilkomen')





# http://docs.oracle.com/javase/tutorial/java/javaOO/enum.html
# http://www.lesismore.co.za/rubyenums.html
# http://gistflow.com/posts/682-ruby-enums-approaches

# http://richhickey.github.io/clojure/clojure.core-api.html
# * agent
# * add-watch
# * apply
# * assert
# * await
# * future
# * memoize
# * promise
# * send
# * slurp

# Other stuff
# * pure - creates an object, freezes it, and removes the unfreeze method
# * retry - retries something x times if it fails
# * promise = ala JavaScript http://blog.parse.com/2013/01/29/whats-so-great-about-javascript-promises/
# * ada range type - http://en.wikibooks.org/wiki/Ada_Programming/Types/range
# * slurpee - slurp + erb parsing
# * spawn/send/receive - http://www.erlang.org/doc/reference_manual/processes.html
# * From Go:
#   - go
#   - channel
#   - defer

# Using Ruby's queue for sending messages between threads
# * http://www.subelsky.com/2010/02/using-rubys-queue-class-to-manage-inter.html
# * http://www.ruby-doc.org/stdlib-1.9.3/libdoc/thread/rdoc/Queue.html#method-i-pop
