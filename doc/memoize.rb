#!/usr/bin/env ruby
$: << File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

require 'functional'

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

if $0 == __FILE__
  run_benchmark(10_000_000)
end

__END__

$ ./doc/memoize.rb
Benchmarks for 10000000 numbers...

With no memoization...
  1.660000   0.000000   1.660000 (  1.657253)

With memoization...
  0.000000   0.000000   0.000000 (  0.000019)

With memoization...
  0.000000   0.000000   0.000000 (  0.000008)
