require 'spec_helper'

module Functional

  describe Memo do

    def create_new_memo_class
      Class.new do
        include Functional::Memo

        class << self
          attr_accessor :count
        end

        self.count = 0

        def foo() nil; end

        def self.add(a, b)
          self.count += 1
          a + b
        end
        memoize :add

        def self.increment(n)
          self.count += 1
        end
      end
    end

    subject{ create_new_memo_class }

    context 'specification' do

      it 'raises an exception when the method is not defined' do
        expect {
          subject.memoize(:bogus)
        }.to raise_error(NameError)
      end

      it 'raises an exception when given an instance method' do
        expect {
          subject.memoize(:foo)
        }.to raise_error(NameError)
      end

      it 'allocates a different cache for each class/module' do
        class_1 = create_new_memo_class
        class_2 = create_new_memo_class

        10.times do
          class_1.add(0, 0)
          class_2.add(0, 0)
        end

        expect(class_1.count).to eq 1
        expect(class_2.count).to eq 1
      end
    end

    context 'caching behavior' do

      it 'calls the real method on first instance of given args' do
        subject.add(1, 2)
        expect(subject.count).to eq 1
      end

      it 'calls the real method on first instance of given args' do
        subject.add(1, 2)
        expect(subject.count).to eq 1
      end

      it 'uses the memo on second instance of given args' do
        5.times { subject.add(1, 2) }
        expect(subject.count).to eq 1
      end

      it 'calls the real method when given a block' do
        5.times { subject.add(1, 2){ nil } }
        expect(subject.count).to eq 5
      end

      it 'raises an exception when arity does not match' do
        expect {
          subject.add
        }.to raise_error(ArgumentError)
      end
    end

    context 'maximum cache size' do

      it 'raises an exception when given a non-positive :at_most' do
        expect {
          subject.memoize(:increment, at_most: -1)
        }.to raise_error(ArgumentError)
      end

      it 'sets no limit when :at_most not given' do
        subject.memoize(:increment)
        10000.times{|i| subject.increment(i) }
        expect(subject.count).to eq 10000
      end

      it 'calls the real method when the :at_most size is reached' do
        subject.memoize(:increment, at_most: 5)
        10000.times{|i| subject.increment(i % 10) }
        expect(subject.count).to eq 5005
      end
    end

    context 'thread safety' do
      pending
    end
  end
end
