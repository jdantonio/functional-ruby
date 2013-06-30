require 'pp'
require 'stringio'
require 'erb'

Infinity = 1/0.0 unless defined?(Infinity)
NaN = 0/0.0 unless defined?(NaN)

module Kernel

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

  # Sandbox the given operation at a high $SAFE level.
  #
  # @param args [Array] zero or more arguments to pass to the block
  # @param block [Proc] the block to isolate
  #
  # @return [Object] the result of the block operation
  def safe(*args)
    raise ArgumentError.new('no block given') unless block_given?
    result = nil
    t = Thread.new do
      $SAFE = 3
      result = yield(*args)
    end
    t.join
    return result
  end
  module_function :safe

  # Open a file, read it, close the file, and return its contents.
  #
  # @param file [String] path to and name of the file to open
  # @return [String] file contents
  #
  # @see slurpee
  def slurp(file)
    File.open(file, 'rb') {|f| f.read }
  end
  module_function :slurp

  # Open a file, read it, close the file, run the contents through the
  # ERB parser, and return updated contents.
  #
  # @param file [String] path to and name of the file to open
  # @param safe_level [Integer] when not nil, ERB will $SAFE set to this
  # @return [String] file contents
  #
  # @see slurpee
  def slurpee(file, safe_level = nil)
    ERB.new(slurp(file), safe_level).result
  end
  module_function :slurpee

  #############################################################################

  # @private
  def repl? # :nodoc:
    return ($0 == 'irb' || $0 == 'pry' || $0 == 'script/rails' || !!($0 =~ /bin\/bundle$/))
  end
  module_function :repl?

  # @private
  def timer(*args) # :nodoc:
    t1 = Time.now
    result = yield(*args)
    t2 = Time.now
    return (t2 - t1)
  end
  module_function :timer

  # @private
  def strftimer(seconds) # :nodoc:
    Time.at(seconds).gmtime.strftime('%R:%S.%L')
  end
  module_function :strftimer

  # @private
  # @see http://rhaseventh.blogspot.com/2008/07/ruby-and-rails-how-to-get-pp-pretty.html
  def pp_s(*objs) # :nodoc:
    s = StringIO.new
    objs.each {|obj|
      PP.pp(obj, s)
    }
    s.rewind
    s.read
  end
  module_function :pp_s
end
