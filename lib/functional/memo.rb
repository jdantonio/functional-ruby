require 'thread'

# http://clojuredocs.org/clojure_core/clojure.core/memoize
module Functional

  module Memo

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:__memo_mutex__=, Mutex.new)
      base.send(:__method_memos__=, {})
      super(base)
    end

    module ClassMethods

      Memo = Struct.new(:function, :cache)

      attr_accessor :__memo_mutex__
      attr_accessor :__method_memos__

      def memoize(func, opts = {})
        func = func.to_sym
        __method_memos__[func] = Memo.new(method(func), {})
        __define_memo_proxy__(func)
      end

      def __define_memo_proxy__(func)
        self.class_eval <<-RUBY
          def self.#{func}(*args)
            self.__proxy_memoized_method(:#{func}, *args)
          end
        RUBY
      end

      def __proxy_memoized_method(func, *args)
        memo = self.__method_memos__[func]
        if memo.cache.has_key?(args)
          memo.cache[args]
        else
          memo.cache[args] = memo.function.call(*args)
        end
      end
    end
  end
end

class Factors
  include Functional::Memo

  def self.sum_of(number)
    of(number).reduce(:+)
  end

  def self.of(number)
    (1..number).select {|i| factor?(number, i)}
  end

  def self.factor?(number, potential)
    number % potential == 0
  end

  def self.perfect?(number)
    sum_of(number) == 2 * number
  end

  def self.abundant?(number)
    sum_of(number) > 2 * number
  end

  def self.deficient?(number)
    sum_of(number) < 2 * number
  end

  memoize(:sum_of)
  memoize(:of)
end

require 'benchmark'
require 'pp'

def memory_usage
  `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
end

def print_memory_usage
  pid, size = memory_usage
  puts "Memory used by process #{pid} at #{Time.now} is #{size}"
end

def run_benchmark(n = 10000)

  puts "Benchmarks for #{n} numbers..."
  puts

  puts 'With no memoization...'
  stats = Benchmark.measure do
    Factors.sum_of(n)
  end
  puts stats

  2.times do
    puts
    puts 'With memoization...'
    stats = Benchmark.measure do
      Factors.sum_of(n)
    end
    puts stats
  end
end

#[15:42:03 Jerry ~/Projects/FOSS/functional-ruby (memoize)]
#$ bc
#Resolving dependencies...
#2.1.2 :001 > load 'lib/functional/memo.rb'
 #=> true
#2.1.2 :002 > run_benchmark(10_000_000)
#Benchmarks for 10000000 numbers...

#With no memoization...
  #1.130000   0.000000   1.130000 (  1.129848)

#With memoization...
  #0.000000   0.000000   0.000000 (  0.000012)

#With memoization...
  #0.000000   0.000000   0.000000 (  0.000005)
