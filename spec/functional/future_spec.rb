require 'spec_helper'

module Functional

  describe Future do

    let!(:fulfilled_value) { 10 }

    let(:pending_future) do
      Future.new{ sleep(1) }
    end

    let(:fulfilled_future) do
      Future.new{ fulfilled_value }.tap(){ sleep(0.1) }
    end

    let(:abended_future) do
      Future.new{ raise StandardException }.tap(){ sleep(0.1) }
    end

    context '#initialize' do

      it 'spawns a new thread when a block is given' do
        t = Thread.new { nil }
        Thread.should_receive(:new).with(any_args()).and_return(t)
        Future.new{ nil }
      end

      it 'does not spawns a new thread when no block given' do
        Thread.should_not_receive(:new).with(any_args())
        Future.new
      end

      it 'immediately sets the state to :fulfilled when no block given' do
        Future.new.should be_fulfilled
      end

      it 'immediately sets the value to nil when no block given' do
        Future.new.value.should be_nil
      end
    end

    context '#state' do

      it 'is :pending when first created' do
        f = pending_future
        f.state.should == :pending
        f.should be_pending
      end

      it 'is :fulfilled when the handler completes' do
        f = fulfilled_future
        f.state.should == :fulfilled
        f.should be_fulfilled
      end

      it 'is :fulfilled when the handler raises an exception' do
        f = abended_future
        f.state.should == :fulfilled
        f.should be_fulfilled
      end
    end

    context '#value' do

      it 'blocks the caller when :pending' do
        f = Future.new{ sleep(1); true }
        sleep(0.1)
        f.value.should be_true
        f.should be_fulfilled
      end

      it 'returns nil when reaching the optional timeout value' do
        f = Future.new{ sleep(1); true }
        sleep(0.1)
        f.value(0.1).should be_nil
        f.should be_pending
      end

      it 'is set to the return value of the handler when complete' do
        fulfilled_future.value.should eq fulfilled_value
      end

      it 'is set to nil when the handler raises an exception' do
        abended_future.value.should be_nil
      end
    end

    context 'fulfillment' do

      it 'passes all arguments to handler' do
        @a = @b = @c = nil
        f = Future.new(1, 2, 3) do |a, b, c|
          @a, @b, @c = a, b, c
        end
        sleep(0.1)
        [@a, @b, @c].should eq [1, 2, 3]
      end

      it 'sets the value to the result of the handler' do
        f = Future.new(10){|a| a * 2 }
        sleep(0.1)
        f.value.should eq 20
      end

      it 'sets the state to :fulfilled when the block completes' do
        f = Future.new(10){|a| a * 2 }
        sleep(0.1)
        f.should be_fulfilled
      end

      it 'sets the value to nil when the handler raises an exception' do
        f = Future.new{ raise StandardError }
        sleep(0.1)
        f.value.should be_nil
      end

      it 'sets the state to :fulfilled when the handler raises an exception' do
        f = Future.new{ raise StandardError }
        sleep(0.1)
        f.should be_fulfilled
      end

      context '#cancel'  do

        let(:dead_thread){ Thread.new{} }
        let(:alive_thread){ Thread.new{ sleep } }

        it 'attempts to kill the thread when :pending' do
          Thread.should_receive(:kill).once.with(any_args()).and_return(dead_thread)
          pending_future.cancel
        end

        it 'returns true when the thread is killed' do
          t = stub('thread', :alive? => false)
          Thread.stub(:kill).once.with(any_args()).and_return(t)
          pending_future.cancel.should be_true
        end

        it 'returns false when the thread is not killed' do
          Thread.stub(:kill).with(any_args()).and_return(alive_thread)
          pending_future.cancel.should be_false
        end

        it 'returns false when :fulfilled' do
          f = fulfilled_future
          f.cancel.should be_false
        end

        it 'sets the value to nil on success' do
          Thread.stub(:kill).once.with(any_args()).and_return(dead_thread)
          f = pending_future
          f.cancel
          f.value.should be_nil
        end

        it 'sets the sate to :fulfilled on success' do
          t = stub('thread', :alive? => false)
          Thread.stub(:kill).once.with(any_args()).and_return(t)
          f = pending_future
          f.cancel
          f.should be_fulfilled
        end
      end

      context 'aliases' do

        it 'aliases #realized? for #fulfilled?' do
          fulfilled_future.should be_realized
        end

        it 'aliases #deref for #value' do
          fulfilled_future.deref.should eq fulfilled_value
        end

        it 'aliases Kernel#future for Future.new' do
          future().should be_a(Future)
          future(){ nil }.should be_a(Future)
          future(1, 2, 3).should be_a(Future)
          future(1, 2, 3){ nil }.should be_a(Future)
        end

        it 'aliases Kernel#deref for #deref' do
          deref(fulfilled_future).should eq fulfilled_value
        end

        it 'aliases Kernel#pending? for #pending?' do
          pending?(pending_future).should be_true
          pending?(fulfilled_future).should be_false
        end

        it 'aliases Kernel#fulfilled? for #fulfilled?' do
          fulfilled?(fulfilled_future).should be_true
          fulfilled?(pending_future).should be_false
        end

        it 'aliases Kernel#realized?? for #realized?' do
          realized?(fulfilled_future).should be_true
          realized?(pending_future).should be_false
        end
      end
    end
  end
end
