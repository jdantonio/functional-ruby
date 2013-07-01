require 'spec_helper'

module Functional

  describe 'concurrency' do

    context '#go' do

      it 'passes all arguments to the block' do
        @expected = nil
        go(1, 2, 3){|a, b, c| @expected = [c, b, a] }
        sleep(0.1)
        @expected.should eq [3, 2, 1]
      end

      it 'returns true if the thread is successfully created' do
        t = Thread.new{ sleep }
        Thread.stub(:new).with(any_args()).and_return(t)
        go{ nil }.should be_true
      end

      it 'returns false if the thread cannot be created' do
        t = Thread.new{ nil }
        t.stub(:alive?).with(no_args()).and_return(false)
        Thread.stub(:new).once.with(any_args()).and_return(t)
        go{ nil }.should be_false
      end

      it 'immediately returns false if no block is given' do
        go().should be_false
      end

      it 'creates a new thread' do
        t = Thread.new{ Thread.pass; sleep(1) }
        Thread.should_receive(:new).with(any_args()).and_return(t)
        go{ nil }
        sleep(0.1)
      end

      it 'does not create a thread if no block is given' do
        Thread.should_not_receive(:new).with(any_args())
        go()
        sleep(0.1)
      end

      it 'supresses exceptions on the thread' do
        lambda{
          go{ raise StandardError }
          sleep(0.1)
        }.should_not raise_error
      end
    end
  end
end
