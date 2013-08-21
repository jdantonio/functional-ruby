require 'pp'
require 'stringio'
require 'erb'
require 'rbconfig'

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

  # Perform an operation numerous times, passing the value of the
  # previous iteration, and collecting the results into an array.
  #
  # @yield iterates over each element in the data set
  # @yieldparam previous the initial value (or nil) for the first
  #   iteration then the value of the previous iteration for all
  #   subsequent iterations
  #
  # @param [Integer] count the number of times to perform the operation
  # @param [Object] initial the initial value to pass to the first iteration
  #
  # @return [Array] the results of the iterations collected into an array
  def repeatedly(count, initial = nil)
    return [] if (count = count.to_i) == 0
    return count.times.collect{ nil } unless block_given?
    return count.times.collect do
      initial = yield(initial)
    end
  end
  module_function :repeatedly

  # Try an operation. If it fails (raises an exception), wait a second
  # and try again. Try no more than the given number of times.
  #
  # @yield Tries the given block operation
  #
  # @param [Integer] tries The maximum number of times to attempt the operation.
  # @param [Array] args Optional block arguments
  #
  # @return [Boolean] true if the operation succeeds on any attempt,
  #   false if none of the attempts are successful
  def retro(tries, *args)
    tries = tries.to_i
    return false if tries == 0 || ! block_given?
    yield(*args)
    return true
  rescue Exception
    sleep(1)
    if (tries = tries - 1) > 0
      retry
    else
      return false
    end
  end
  module_function :retro

  # Sandbox the given operation at a high $SAFE level.
  #
  # @param args [Array] zero or more arguments to pass to the block
  #
  # @return [Object] the result of the block operation
  def safe(*args)
    raise ArgumentError.new('no block given') unless block_given?
    if RbConfig::CONFIG['ruby_install_name'] =~ /^ruby$/i
      result = nil
      t = Thread.new do
        $SAFE = 3
        result = yield(*args)
      end
      t.join
      return result
    else
      return yield(*args)
    end
  end
  module_function :safe

  # Open a file, read it, close the file, and return its contents.
  #
  # @param file [String] path to and name of the file to open
  #
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
  #
  # @return [String] file contents
  #
  # @see slurpee
  def slurpee(file, safe_level = nil)
    ERB.new(slurp(file), safe_level).result
  end
  module_function :slurpee

  # Run the given block and time how long it takes in seconds. All arguments
  # will be passed to the block. The function will return two values. The
  # first value will be the duration of the timer in seconds. The second
  # return value will be the result of the block.
  #
  # @param args [Array] zero or more arguments to pass to the block
  #
  # @return [Integer, Object] the duration of the operation in seconds and
  #   the result of the block operation
  def timer(*args)
    return 0,nil unless block_given?
    t1 = Time.now
    result = yield(*args)
    t2 = Time.now
    return (t2 - t1), result
  end
  module_function :timer

  #############################################################################

  # @private
  # @see http://cirw.in/blog/find-references
  def object_counts # :nodoc:
    counts = Hash.new{ 0 }
    ObjectSpace.each_object do |obj|
      counts[obj.class] += 1
    end
    return counts
  end
  module_function :object_counts

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

  # @private
  def repl? # :nodoc:
    return ($0 == 'irb' || $0 == 'pry' || $0 == 'script/rails' || !!($0 =~ /bin\/bundle$/))
  end
  module_function :repl?

  # @private
  def strftimer(seconds) # :nodoc:
    Time.at(seconds).gmtime.strftime('%R:%S.%L')
  end
  module_function :strftimer

  # @private
  def timestamp # :nodoc:
    return Time.now.getutc.to_i
  end

  def write_object_counts(name = 'ruby')
    file = "#{name}_#{Time.now.to_i}.txt"
    File.open(file, 'w') {|f| f.write(pp_s(object_counts)) }
  end
  module_function :write_object_counts
end
