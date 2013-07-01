require 'spec_helper'

module Functional

  describe Promise do

    let!(:fulfilled_value) { 10 }
    let!(:rejected_reason) { StandardError.new('mojo jojo') }

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

    context 'behavior' do

      it 'implements :promise behavior' do
        lambda {
          Promise.new{ nil }
        }.should_not raise_error(BehaviorError)

        Promise.new{ nil }.behaves_as?(:promise).should be_true
      end

      it 'implements :future behavior' do
        lambda {
          Promise.new{ nil }
        }.should_not raise_error(BehaviorError)

        Promise.new{ nil }.behaves_as?(:future).should be_true
      end
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

      it 'is set to error object of the exception when :rejected' do
        rejected_promise.reason.should be_a(Exception)
        rejected_promise.reason.to_s.should =~ /#{rejected_reason}/
      end
    end

    context '#then' do

      it 'returns a new Promise when :pending' do
        p1 = pending_promise
        p2 = p1.then{}
        p2.should be_a(Promise)
        p1.should_not eq p2
      end

      it 'returns a new Promise when :fulfilled' do
        p1 = fulfilled_promise
        p2 = p1.then{}
        p2.should be_a(Promise)
        p1.should_not eq p2
      end

      it 'returns a new Promise when :rejected' do
        p1 = rejected_promise
        p2 = p1.then{}
        p2.should be_a(Promise)
        p1.should_not eq p2
      end

      it 'immediately rejects new promises when self has been rejected' do
        p = rejected_promise
        p.then.should be_rejected
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
        Promise.new(10){|a| a * 2 }.then{|result| @expected = result}
        sleep(0.1)
        @expected.should eq 20
      end

      it 'sets the promise value to the result if its block' do
        p = Promise.new(10){|a| a * 2 }.then{|result| result * 2}
        sleep(0.1)
        p.value.should eq 40
      end

      it 'sets the promise state to :fulfilled if the block completes' do
        p = Promise.new(10){|a| a * 2 }.then{|result| result * 2}
        sleep(0.1)
        p.should be_fulfilled
      end

      it 'passes the last result through when a promise has no block' do
        @expected = nil
        Promise.new(10){|a| a * 2 }.then.then{|result| @expected = result}
        sleep(0.1)
        @expected.should eq 20
      end
    end

    context 'rejection' do

      it 'sets the promise reason the error object on exception' do
        p = Promise.new{ raise StandardError.new('Boom!') }
        sleep(0.1)
        p.reason.should be_a(Exception)
        p.reason.should.to_s =~ /Boom!/
      end

      it 'sets the promise state to :rejected on exception' do
        p = Promise.new{ raise StandardError.new('Boom!') }
        sleep(0.1)
        p.should be_rejected
      end

      it 'recursively rejects all children' do
        p = Promise.new{ Thread.pass; raise StandardError.new('Boom!') }
        promises = 10.times.collect{ p.then{ true } }
        sleep(0.1)

        10.times.each{|i| promises[i].should be_rejected }
      end

      it 'skips processing rejected promises' do
        p = Promise.new{ raise StandardError.new('Boom!') }
        promises = 3.times.collect{ p.then{ true } }
        sleep(0.1)
        promises.each{|p| p.value.should_not be_true }
      end

      it 'calls the first exception block with a matching class' do
        @expected = nil
        Promise.new{ raise StandardError }.
          rescue(StandardError){|ex| @expected = 1 }.
          rescue(StandardError){|ex| @expected = 2 }.
          rescue(StandardError){|ex| @expected = 3 }
          sleep(0.1)
        @expected.should eq 1
      end

      it 'matches all with a rescue with no class given' do
        @expected = nil
        Promise.new{ raise NoMethodError }.
          rescue(LoadError){|ex| @expected = 1 }.
          rescue{|ex| @expected = 2 }.
          rescue(StandardError){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 2
      end

      it 'searches associated rescue handlers in order' do
        @expected = nil
        Promise.new{ raise ArgumentError }.
          rescue(ArgumentError){|ex| @expected = 1 }.
          rescue(LoadError){|ex| @expected = 2 }.
          rescue(Exception){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 1

        @expected = nil
        Promise.new{ raise LoadError }.
          rescue(ArgumentError){|ex| @expected = 1 }.
          rescue(LoadError){|ex| @expected = 2 }.
          rescue(Exception){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 2

        @expected = nil
        Promise.new{ raise StandardError }.
          rescue(ArgumentError){|ex| @expected = 1 }.
          rescue(LoadError){|ex| @expected = 2 }.
          rescue(Exception){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 3
      end

      it 'passes the exception object to the matched block' do
        @expected = nil
        Promise.new{ raise StandardError }.
          rescue(ArgumentError){|ex| @expected = ex }.
          rescue(LoadError){|ex| @expected = ex }.
          rescue(Exception){|ex| @expected = ex }
        sleep(0.1)
        @expected.should be_a(StandardError)
      end

      it 'ignores rescuers without a block' do
        @expected = nil
        Promise.new{ raise StandardError }.
          rescue(StandardError).
          rescue(StandardError){|ex| @expected = ex }.
          rescue(Exception){|ex| @expected = ex }
        sleep(0.1)
        @expected.should be_a(StandardError)
      end

      it 'supresses the exception if no rescue matches' do
        lambda {
          Promise.new{ raise StandardError }.
            rescue(ArgumentError){|ex| @expected = ex }.
            rescue(StandardError){|ex| @expected = ex }.
            rescue(Exception){|ex| @expected = ex }
          sleep(0.1)
        }.should_not raise_error
      end

      it 'supresses exceptions thrown from rescue handlers' do
        lambda {
          Promise.new{ raise ArgumentError }.
          rescue(Exception){ raise StandardError }
          sleep(0.1)
        }.should_not raise_error(StandardError)
      end

      it 'calls matching rescue handlers on all children' do
        @expected = []
        Promise.new{ Thread.pass; raise StandardError }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }
        sleep(0.1)

        @expected.length.should eq 5
      end
    end

    context 'aliases' do

      it 'aliases #realized? for #fulfilled?' do
        fulfilled_promise.should be_realized
      end

      it 'aliases #deref for #value' do
        fulfilled_promise.deref.should eq fulfilled_value
      end

      it 'aliases #catch for #rescue' do
        @expected = nil
        Promise.new{ raise StandardError }.catch{ @expected = true }
        sleep(0.1)
        @expected.should be_true
      end

      it 'aliases #on_error for #rescue' do
        @expected = nil
        Promise.new{ raise StandardError }.on_error{ @expected = true }
        sleep(0.1)
        @expected.should be_true
      end

      it 'aliases Kernel#promise for Promise.new' do
        promise().should be_a(Promise)
        promise(){ nil }.should be_a(Promise)
        promise(1, 2, 3).should be_a(Promise)
        promise(1, 2, 3){ nil }.should be_a(Promise)
      end

      it 'aliases Kernel#deref for #deref' do
        deref(fulfilled_promise).should eq fulfilled_value
      end

      it 'aliases Kernel#pending? for #pending?' do
        pending?(pending_promise).should be_true
        pending?(fulfilled_promise).should be_false
        pending?(rejected_promise).should be_false
      end

      it 'aliases Kernel#fulfilled? for #fulfilled?' do
        fulfilled?(fulfilled_promise).should be_true
        fulfilled?(pending_promise).should be_false
        fulfilled?(rejected_promise).should be_false
      end

      it 'aliases Kernel#realized? for #realized?' do
        realized?(fulfilled_promise).should be_true
        realized?(pending_promise).should be_false
        realized?(rejected_promise).should be_false
      end

      it 'aliases Kernel#rejected? for #rejected?' do
        rejected?(rejected_promise).should be_true
        rejected?(fulfilled_promise).should be_false
        rejected?(pending_promise).should be_false
      end
    end
  end
end
