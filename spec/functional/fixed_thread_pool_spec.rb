require 'spec_helper'

module Functional

  describe FixedThreadPool do

    subject { FixedThreadPool.new(1) }

    context '#initialize' do

      it 'raises an exception when the pool size is less than one' do
        lambda {
          FixedThreadPool.new(0)
        }.should raise_error(ArgumentError)
      end

      it 'raises an exception when the pool size is greater than 1024' do
        lambda {
          FixedThreadPool.new(1025)
        }.should raise_error(ArgumentError)
      end

      it 'creates a thread pool of the given size' do
        thread = mock('thread')
        Thread.should_receive(:new).exactly(5).times.and_return(thread)
        pool = FixedThreadPool.new(5)
        pool.size.should eq 5
      end
    end

    context '#running?' do

      it 'returns true when the subject is running' do
        subject.should be_running
      end

      it 'returns false when the subject is shutting down' do
        subject.post{ sleep(1) }
        subject.shutdown
        subject.should_not be_running
      end

      it 'returns false when the subject is shutdown' do
        subject.shutdown
        subject.should_not be_running
      end

      it 'returns false when the subject is terminated' do
        subject.shutdown
        subject.should_not be_running
      end
    end

    context '#shutdown?' do

      it 'returns true if #shutdown has been called' do
        subject.shutdown
        subject.should be_shutdown
      end

      it 'returns false when running' do
        subject.should_not be_shutdown
      end
    end

    context '#terminated?' do

      it 'returns true if all tasks were completed after shutdown' do
        subject.post{ sleep(0.5) }
        subject.shutdown
        sleep(1)
        subject.should be_terminated
      end

      it 'returns false if tasks were killed after shutdown' do
        subject.post{ sleep(1) }
        subject.kill
        subject.should_not be_terminated
      end

      it 'returns false when running' do
        subject.should_not be_terminated
      end
    end

    context '#shutdown' do

      it 'stops accepting new tasks' do
        subject.post{ sleep(1) }
        subject.shutdown
        @expected = false
        subject.post{ @expected = true }.should be_false
        sleep(1)
        @expected.should be_false
      end

      it 'allows in-progress tasks to complete' do
        @expected = false
        subject.post{ sleep(1); @expected = true }
        subject.shutdown
        sleep(1)
        @expected.should be_true
      end

      it 'allows pending tasks to complete' do
        @expected = false
        subject.post{ sleep(0.2) }
        subject.post{ sleep(0.2); @expected = true }
        subject.shutdown
        sleep(1)
        @expected.should be_true
      end

      it 'allows threads to exit normally' do
        pool = FixedThreadPool.new(5)
        pool.shutdown
        sleep(1)
        pool.status.should eq [false, false, false, false, false]
      end

      it 'returns immediately (does not block)' do
        pending
        pool = FixedThreadPool.new(1)
        pool.shutdown
      end
    end

    context '#kill' do

      subject{ FixedThreadPool.new(5) }

      it 'stops accepting new tasks' do
        subject.post{ sleep(1) }
        subject.kill
        @expected = false
        subject.post{ @expected = true }.should be_false
        sleep(1)
        @expected.should be_false
      end

      it 'attempts to kill all in-progress tasks' do
        @expected = false
        subject.post{ sleep(1); @expected = true }
        subject.kill
        sleep(1)
        @expected.should be_false
      end

      it 'rejects all pending tasks' do
        @expected = false
        subject.post{ sleep(0.5) }
        subject.post{ sleep(0.5); @expected = true }
        subject.kill
        sleep(1)
        @expected.should be_false
      end

      it 'kills all threads' do
        Thread.should_receive(:kill).exactly(5).times
        pool = FixedThreadPool.new(5)
        pool.kill
        sleep(0.1)
      end

      it 'returns immediately (does not block)' do
        pending
        pool = FixedThreadPool.new(1)
        pool.kill
      end
    end

    context '#size' do

      let(:pool_size) { 3 }
      subject { FixedThreadPool.new(pool_size) }

      it 'returns the size of the subject when running' do
        subject.size.should eq pool_size
      end

      it 'returns zero while shutting down' do
        subject.post{ sleep(1) }
        subject.shutdown
        subject.size.should eq 0
      end

      it 'returns zero once shut down' do
        subject.shutdown
        subject.size.should eq 0
      end
    end

    context '#wait_for_termination' do

      it 'immediately returns true after shutdown has complete' do
        subject.shutdown
        subject.wait_for_termination.should be_true
      end

      it 'blocks indefinitely when timeout it nil' do
        subject.post{ sleep(1) }
        subject.shutdown
        subject.wait_for_termination(nil).should be_true
      end

      it 'returns true when shutdown sucessfully completes before timeout' do
        subject.post{ sleep(0.5) }
        subject.shutdown
        subject.wait_for_termination(1).should be_true
      end

      it 'returns false when shutdown fails to complete before timeout' do
        subject.post{ sleep(1) }
        subject.shutdown
        subject.wait_for_termination(0.5).should be_true
      end
    end

    context '#post' do

      it 'raises an exception if no block is given' do
        lambda {
          pool = FixedThreadPool.new(1)
          pool.post
        }.should raise_error(ArgumentError)
      end

      it 'returns true when the block is added to the queue' do
        subject.post{ nil }.should be_true
      end

      it 'calls the block with the given arguments' do
        @expected = nil
        subject.post(1, 2, 3)do |a, b, c|
          @expected = a + b + c
        end
        sleep(0.1)
        @expected.should eq 6
      end

      it 'rejects the block while shutting down' do
        pool = FixedThreadPool.new(5)
        pool.post{ sleep(1) }
        pool.shutdown
        @expected = nil
        pool.post(1, 2, 3)do |a, b, c|
          @expected = a + b + c
        end
        @expected.should be_nil
      end

      it 'returns false while shutting down' do
        subject.post{ sleep(1) }
        subject.shutdown
        subject.post{ nil }.should be_false
      end

      it 'rejects the block once shutdown' do
        pool = FixedThreadPool.new(5)
        pool.shutdown
        @expected = nil
        pool.post(1, 2, 3)do |a, b, c|
          @expected = a + b + c
        end
        @expected.should be_nil
      end

      it 'returns false once shutdown' do
        subject.post{ nil }
        subject.shutdown
        sleep(0.1)
        subject.post{ nil }.should be_false
      end

      it 'aliases #<<' do
        @expected = false
        subject << proc { @expected = true }
        sleep(0.1)
        @expected.should be_true
      end
    end

    context 'exception handling' do
      it 'restarts dead threads'
    end
  end
end
