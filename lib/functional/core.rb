require 'pp'
require 'stringio'
require 'erb'

Infinity = 1/0.0 unless defined?(Infinity)
NaN = 0/0.0 unless defined?(NaN)

module Kernel

  private

  def repl?
    return ($0 == 'irb' || $0 == 'pry' || $0 == 'script/rails' || !!($0 =~ /bin\/bundle$/))
  end
  module_function :repl?

  def safe(*args, &block)
    raise ArgumentError.new('no block given') unless block_given?
    result = nil
    t = Thread.new do
      $SAFE = 3
      result = self.instance_exec(*args, &block)
    end
    t.join
    return result
  end
  module_function :safe

  # http://rhaseventh.blogspot.com/2008/07/ruby-and-rails-how-to-get-pp-pretty.html
  def pp_s(*objs)
    s = StringIO.new
    objs.each {|obj|
      PP.pp(obj, s)
    }
    s.rewind
    s.read
  end
  module_function :pp_s

  def slurp(file)
    File.open(file, 'rb') {|f| f.read }
  end
  module_function :slurp

  def slurpee(file, safe = nil)
    ERB.new(slurp(file), safe).result
  end
  module_function :slurpee

  # Compute the difference (delta) between two values.
  # 
  # When a block is given the block will be applied to both arguments.
  # Using a block in this way allows computation against a specific field
  # in a data set of hashes or objects.
  #
  # @yield iterates over each element in the data set
  # @yieldparam item each element in the data set
  #
  # @param [Object] v1 the first value
  # @param [Object] v2 the second value
  #
  # @return [Float] positive value representing the difference
  #   between the two parameters
  def delta(v1, v2)
    if block_given?
      v1 = yield(v1)
      v2 = yield(v2)
    end
    return (v1 - v2).abs
  end
  module_function :delta

end
