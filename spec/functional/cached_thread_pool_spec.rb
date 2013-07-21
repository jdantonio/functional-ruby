require 'spec_helper'
require_relative 'thread_pool_shared'

module Functional

  describe CachedThreadPool do

    subject { CachedThreadPool.new }

    it_should_behave_like 'Thread Pool'

    context '#initialize' do
      it 'aliases Functional#new_cached_thread_pool' do
        pool = Functional.new_cached_thread_pool
        pool.should be_a(CachedThreadPool)
        pool.size.should eq 0
      end
    end

    context '#kill' do

      it 'kills all threads' do
        Thread.should_receive(:kill).exactly(5).times
        pool = CachedThreadPool.new
        5.times{ sleep(0.1); pool << proc{ sleep(1) } }
        sleep(1)
        pool.kill
        sleep(0.1)
      end
    end

    context '#size' do

      it 'returns zero for a new thread pool' do
        subject.size.should eq 0
      end

      it 'returns the size of the subject when running' do
        5.times{ sleep(0.1); subject << proc{ sleep(1) } }
        subject.size.should eq 5
      end

      it 'returns zero once shut down' do
        subject.shutdown
        subject.size.should eq 0
      end
    end

    context 'worker creation and caching' do

      it 'creates new workers when there are none available' do
        subject.size.should eq 0
        5.times{ subject << proc{ sleep(0.5) } }
        subject.size.should eq 5
      end

      it 'uses existing idle threads' do
        5.times{ subject << proc{ nil } }
        sleep(1)
        3.times{ subject << proc{ sleep(0.5) } }
        subject.size.should eq 5
      end
    end

    context 'exception handling' do
      it 'allows threads to die' do
        pending "I have no idea how to test this"
      end
    end

    context 'garbage collection' do

      it 'kills any thread that has been idle more than 60 seconds' do
        pending "I have no idea how to test this"
      end
    end
  end
end
