require 'spec_helper'

module Functional

  describe Promise do

    let!(:fulfilled_value) { 10 }
    let!(:rejected_reason) { 'mojo jojo' }

    let(:pending_promise) do
      Promise.new{ sleep(1) }
    end

    let(:fulfilled_promise) do
      Promise.new{ fulfilled_value }.tap(){ sleep(0.1) }
    end

    let(:rejected_promise) do
      Promise.new{ raise StandardError.new(rejected_reason) }.
        rescue{ nil }.tap(){ sleep(0.1) }
    end

    context '#state' do

      it 'is :pending when first created' do
        p = pending_promise
        p.state.should == :pending
        p.should be_pending
      end

      it 'is :fulfilled on success' do
        p = fulfilled_promise
        p.state.should == :fulfilled
        p.should be_fulfilled
      end

      it 'is :rejected on error' do
        p = rejected_promise
        p.state.should == :rejected
        p.should be_rejected
      end

      it 'is not frozen when :pending' do
        p = pending_promise
        p.should_not be_frozen
      end

      it 'is frozen when :fulfilled' do
        p = fulfilled_promise
        p.should be_frozen
      end

      it 'is frozen when :rejected' do
        p = rejected_promise
        p.should be_frozen
      end
    end

    context '#value' do

      it 'is nil when :pending' do
        pending_promise.value.should be_nil
      end

      it 'is nil when :rejected' do
        rejected_promise.value.should be_nil
      end

      it 'is set to the return value of the block when :fulfilled' do
        fulfilled_promise.value.should eq fulfilled_value
      end
    end

    context '#reason' do

      it 'is nil when :pending' do
        pending_promise.reason.should be_nil
      end

      it 'is nil when :fulfilled' do
        fulfilled_promise.reason.should be_nil
      end

      it 'is set to the message of the exception when :rejected' do
        rejected_promise.reason.should =~ /#{rejected_reason}/
      end
    end

    context '#then' do

      it 'returns a new Promise when :pending' do
        p1 = pending_promise
        p2 = p1.then{}
        p2.should be_a(Promise)
        p1.should_not eq p2
      end

      it 'returns self when :fulfilled' do
        p1 = fulfilled_promise
        p2 = p1.then{}
        p2.should be_a(Promise)
        p1.object_id.should eq p2.object_id
      end

      it 'returns self when :rejected' do
        p1 = rejected_promise
        p2 = p1.then{}
        p2.should be_a(Promise)
        p1.object_id.should eq p2.object_id
      end

      it 'accepts a nil block' do
        lambda {
          pending_promise.then
        }.should_not raise_error
      end

      it 'can be called more than once' do
        p = pending_promise
        p1 = p.then{}
        p2 = p.then{}
        p1.object_id.should_not eq p2.object_id
      end
    end

    context '#rescue' do

      it 'returns self when a block is given' do
        p1 = pending_promise
        p2 = p1.rescue{}
        p1.object_id.should eq p2.object_id
      end

      it 'returns self when no block is given' do
        p1 = pending_promise
        p2 = p1.rescue
        p1.object_id.should eq p2.object_id
      end

      it 'accepts an exception class as the first parameter' do
        lambda {
          pending_promise.rescue(StandardError){}
        }.should_not raise_error
      end

      it 'defaults to Exception when no class is given' do
        pending
      end
    end

    context 'fulfillment' do

      it 'passes all arguments to the first promise in the chain' do
        @a = @b = @c = nil
        p = Promise.new(1, 2, 3) do |a, b, c|
          @a, @b, @c = a, b, c
        end
        sleep(0.1)
        [@a, @b, @c].should eq [1, 2, 3]
      end
      
      it 'passes the result of each block to all its children' do
        @expected = nil
        promise(10){|a| a * 2 }.then{|result| @expected = result}
        sleep(0.1)
        @expected.should eq 20
      end

      it 'sets the promise value to the result if its block' do
        p = promise(10){|a| a * 2 }.then{|result| result * 2}
        sleep(0.1)
        p.value.should eq 40
      end

      it 'sets the promise state to :fulfilled if the block completes' do
        p = promise(10){|a| a * 2 }.then{|result| result * 2}
        sleep(0.1)
        p.should be_fulfilled
      end

      it 'passes the last result through when a promise has no block' do
        @expected = nil
        promise(10){|a| a * 2 }.then.then{|result| @expected = result}
        sleep(0.1)
        @expected.should eq 20
      end
    end

    context 'rejection' do

      it 'sets the promise reason to an error message on exception' do
        pending
      end

      it 'sets the promise state to :rejected on exception' do
        pending
      end

      it 'recursively rejects all children' do
        pending
      end

      it 'skips processing rejected promises do
        pending
      end'

      it 'searches all associated rescue blocks in order' do
        pending
      end

      it 'calls the first exception block with a matching class' do
        pending
      end

      it 'passes the exception object to the matched block' do
        pending
      end

      it 'bubbles to the parent when there are no rescue blocks' do
        pending
      end

      it 'bubbles to the parent when no exception blocks match' do
        pending
      end

      it 'ignores rescuers without a block' do
        pending
      end

      it 'raises the exception if no rescue matches' do
        pending
      end
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
  sleep(15)
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
