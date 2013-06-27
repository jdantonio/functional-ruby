require 'spec_helper'

module Functional

  describe Promise do

    context '#initialize' do
      pending
    end

    context '#then' do
    end

    context '#rescue' do
    end
  end
end

require 'functional/promise'

def go_bad
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  p = promise{ puts 'starting...'; sleep(1); puts 'good' }.
    then{|result| puts 'raising exception...'; raise StandardError.new('Boom!') }.
    rescue{|ex| puts ex.message }
  p.then{|result| sleep(1); puts 'Pow!'}
  sleep(2)
  puts "---> #{p.reason}"
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
end

def go_big
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  p = promise(1, 2, 3){|one, two, three| nil }.
    then{|result| sleep(1); puts 1 }.
    then{|result| sleep(1); puts 2 }.
    then{|result| sleep(1); puts 3 }.
    then{|result| sleep(1); puts 4 }.
    then{|result| sleep(1); puts 5 }.
    then{|result| sleep(1); puts 6 }.
    then{|result| sleep(1); puts 7 }.
    then{|result| sleep(1); puts 8 }
  sleep(10)
  p.then{|result| sleep(1); puts 'Boom!'}.
    then{|result| sleep(1); puts 'Bam!'}
  p.then{|result| sleep(1); puts 'Pow!'}
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
end

class Foo
  def bar(&block)
    return promise(&block)
  end
end

def go_foo
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  Foo.new.bar{ puts 'Boom!' }.
    then{|result| puts 'Bam!'}.
    then.
    rescue.
    then{|result| puts 'Pow!'}.
    then
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
end
