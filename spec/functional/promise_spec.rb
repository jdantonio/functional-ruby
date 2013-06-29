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
        p = promise{ raise StandardError.new('Boom!') }
        sleep(0.1)
        p.reason.should =~ /Boom!/
      end

      it 'sets the promise state to :rejected on exception' do
        p = promise{ raise StandardError.new('Boom!') }
        sleep(0.1)
        p.should be_rejected
      end

      it 'recursively rejects all children' do
        p = promise{ Thread.pass; raise StandardError.new('Boom!') }
        promises = 3.times.collect{ p.then{ true } }
        sleep(0.1)

        #NOTE: The exact size of array 'p' cannot be predicted because
        # it is impossible to time precisely when the root promise will
        # abend. Testing concurrency is hard...
        promises.each{|p| p.should be_rejected }
      end

      it 'skips processing rejected promises' do
        p = promise{ raise StandardError.new('Boom!') }
        promises = 3.times.collect{ p.then{ true } }
        sleep(0.1)
        promises.each{|p| p.value.should_not be_true }
      end

      it 'calls the first exception block with a matching class' do
        @expected = nil
        promise{ raise StandardError }.
          rescue(StandardError){|ex| @expected = 1 }.
          rescue(StandardError){|ex| @expected = 2 }.
          rescue(StandardError){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 1
      end

      it 'matches all with a rescue with no class given' do
        @expected = nil
        promise{ raise NoMethodError }.
          rescue(LoadError){|ex| @expected = 1 }.
          rescue{|ex| @expected = 2 }.
          rescue(StandardError){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 2
      end

      it 'searches associated rescue handlers in order' do
        @expected = nil
        promise{ raise ArgumentError }.
          rescue(ArgumentError){|ex| @expected = 1 }.
          rescue(LoadError){|ex| @expected = 2 }.
          rescue(Exception){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 1

        @expected = nil
        promise{ raise LoadError }.
          rescue(ArgumentError){|ex| @expected = 1 }.
          rescue(LoadError){|ex| @expected = 2 }.
          rescue(Exception){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 2

        @expected = nil
        promise{ raise StandardError }.
          rescue(ArgumentError){|ex| @expected = 1 }.
          rescue(LoadError){|ex| @expected = 2 }.
          rescue(Exception){|ex| @expected = 3 }
        sleep(0.1)
        @expected.should eq 3
      end

      it 'passes the exception object to the matched block' do
        @expected = nil
        promise{ raise StandardError }.
          catch(ArgumentError){|ex| @expected = ex }.
          catch(LoadError){|ex| @expected = ex }.
          catch(Exception){|ex| @expected = ex }
        sleep(0.1)
        @expected.should be_a(StandardError)
      end

      it 'ignores rescuers without a block' do
        @expected = nil
        promise{ raise StandardError }.
          rescue(StandardError).
          rescue(StandardError){|ex| @expected = ex }.
          rescue(Exception){|ex| @expected = ex }
        sleep(0.1)
        @expected.should be_a(StandardError)
      end

      it 'supresses the exception if no rescue matches' do
        lambda {
          promise{ raise StandardError }.
            rescue(ArgumentError){|ex| @expected = ex }.
            rescue(StandardError){|ex| @expected = ex }.
            rescue(Exception){|ex| @expected = ex }
          sleep(0.1)
        }.should_not raise_error
      end

      it 'supresses exceptions thrown from rescue handlers' do
        lambda {
          promise{ raise ArgumentError }.
            rescue(Exception){ raise StandardError }
          sleep(0.1)
        }.should_not raise_error(StandardError)
      end

      it 'calls matching rescue handlers on all children' do
        @expected = []
        promise{ Thread.pass; raise StandardError }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }.
          then{ sleep(0.1) }.rescue{ @expected << 'Boom!' }
        sleep(0.1)

        #NOTE: The exact size of @expected cannot be predicted because
        # it is impossible to time precisely when the root promise will
        # abend. Testing concurrency is hard...
        @expected.should_not be_empty
      end
    end
  end
end
