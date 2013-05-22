# trying to figure you why inheritance doesn't work
# how I want it to

#module Super

  #def self.included(base)
    #puts "#{base} included #{self}"
    #base.send(:define_method, :zoom) { 'zoom' }

    #class << base
      #puts "#{self}"
      #puts "#{self.class}"
    #end
  #end
#end

#class Foo
  #include Super
  #def hi
    #return 'ho'
  #end
  #self.send(:define_method, :ho) { 'hi' }
#end

#class Bar < Foo
#end

#class Baz < Bar
#end

require_relative 'lib/pattern_matching'

class Foo
  include PatternMatching
  defn(:greet) { puts 'hi' }
  def hello
    puts 'hello'
  end
  puts "!!!! #{self}"
  define_method(:boom) {|*args, &block| puts 'Boom!' }
  class << self
    define_method(:bam) { puts 'Bam!' }
  end
end

class Bar < Foo
end
