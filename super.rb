# trying to figure you why inheritance doesn't work
# how I want it to

module Super

  def self.included(base)
    #puts "#{base} included #{self}"
    base.send(:define_method, :zoom) { 'zoom' }

    #class << base
      #puts "#{self}"
      #puts "#{self.class}"
    #end
  end
end

class Sooperclass
  include Super
  def hi
    return 'ho'
  end
  self.send(:define_method, :ho) { 'hi' }
end

class Mainclass < Sooperclass
end

class Subclass < Mainclass
end

require_relative 'lib/pattern_matching'

class Foo
  include PatternMatching

  defn(:greet) {
    'hi'
  }

  def hello
    'hello'
  end

  define_method(:boom) {|*args, &block|
    'Boom!'
  }

  class << self
    define_method(:bam) {
      'Bam!'
    }
  end
end

class Bar < Foo
end

foo = Foo.new
bar = Bar.new

sooper = Sooperclass.new
main = Mainclass.new
sub = Subclass.new
