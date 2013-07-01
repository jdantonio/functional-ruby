require 'spec_helper'

module Functional

  describe Future do

    let!(:fulfilled_value) { 10 }
    let!(:rejected_reason) { StandardError.new('mojo jojo') }

    let(:pending_subject) do
      Future.new{ sleep(1) }
    end

    let(:fulfilled_subject) do
      Future.new{ fulfilled_value }.tap(){ sleep(0.1) }
    end

    let(:rejected_subject) do
      Future.new{ raise rejected_reason }.tap(){ sleep(0.1) }
    end

    context 'behavior' do

      it 'implements :future behavior' do
        lambda {
          Future.new{ nil }
        }.should_not raise_error(BehaviorError)

        Future.new{ nil }.behaves_as?(:future).should be_true
      end
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
        f = pending_subject
        f.state.should == :pending
        f.should be_pending
      end

      it 'is :fulfilled when the handler completes' do
        f = fulfilled_subject
        f.state.should == :fulfilled
        f.should be_fulfilled
      end

      it 'is :rejected when the handler raises an exception' do
        f = rejected_subject
        f.state.should == :rejected
        f.should be_rejected
      end
    end

    context '#value' do

      it 'blocks the caller when :pending' do
        f = pending_subject
        sleep(0.1)
        f.value.should be_true
        f.should be_fulfilled
      end

      it 'returns nil when reaching the optional timeout value' do
        f = pending_subject
        sleep(0.1)
        f.value(0.1).should be_nil
        f.should be_pending
      end

      it 'is nil when :pending' do
        pending_subject.value.should be_nil
      end

      it 'is nil when :rejected' do
        rejected_subject.value.should be_nil
      end

      it 'is set to the return value of the block when :fulfilled' do
        fulfilled_subject.value.should eq fulfilled_value
      end
    end

    context '#reason' do

      it 'is nil when :pending' do
        pending_subject.reason.should be_nil
      end

      it 'is nil when :fulfilled' do
        fulfilled_subject.reason.should be_nil
      end

      it 'is set to error object of the exception when :rejected' do
        rejected_subject.reason.should be_a(Exception)
        rejected_subject.reason.to_s.should =~ /#{rejected_reason}/
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

      it 'sets the state to :rejected when the handler raises an exception' do
        f = Future.new{ raise StandardError }
        sleep(0.1)
        f.should be_rejected
      end

      context '#cancel'  do

        let(:dead_thread){ Thread.new{} }
        let(:alive_thread){ Thread.new{ sleep } }

        it 'attempts to kill the thread when :pending' do
          Thread.should_receive(:kill).once.with(any_args()).and_return(dead_thread)
          pending_subject.cancel
        end

        it 'returns true when the thread is killed' do
          t = stub('thread', :alive? => false)
          Thread.stub(:kill).once.with(any_args()).and_return(t)
          pending_subject.cancel.should be_true
        end

        it 'returns false when the thread is not killed' do
          Thread.stub(:kill).with(any_args()).and_return(alive_thread)
          pending_subject.cancel.should be_false
        end

        it 'returns false when :fulfilled' do
          f = fulfilled_subject
          f.cancel.should be_false
        end

        it 'sets the value to nil on success' do
          Thread.stub(:kill).once.with(any_args()).and_return(dead_thread)
          f = pending_subject
          f.cancel
          f.value.should be_nil
        end

        it 'sets the sate to :fulfilled on success' do
          t = stub('thread', :alive? => false)
          Thread.stub(:kill).once.with(any_args()).and_return(t)
          f = pending_subject
          f.cancel
          f.should be_fulfilled
        end
      end

      context 'aliases' do

        it 'aliases #realized? for #fulfilled?' do
          fulfilled_subject.should be_realized
        end

        it 'aliases #deref for #value' do
          fulfilled_subject.deref.should eq fulfilled_value
        end

        it 'aliases Kernel#future for Future.new' do
          future().should be_a(Future)
          future(){ nil }.should be_a(Future)
          future(1, 2, 3).should be_a(Future)
          future(1, 2, 3){ nil }.should be_a(Future)
        end

        it 'aliases Kernel#deref for #deref' do
          deref(fulfilled_subject).should eq fulfilled_value
        end

        it 'aliases Kernel#pending? for #pending?' do
          pending?(pending_subject).should be_true
          pending?(fulfilled_subject).should be_false
        end

        it 'aliases Kernel#fulfilled? for #fulfilled?' do
          fulfilled?(fulfilled_subject).should be_true
          fulfilled?(pending_subject).should be_false
        end

        it 'aliases Kernel#realized?? for #realized?' do
          realized?(fulfilled_subject).should be_true
          realized?(pending_subject).should be_false
        end
      end
    end
  end
end
