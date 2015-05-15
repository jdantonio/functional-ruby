module Functional

  describe Memo do

    def create_new_memo_class
      Class.new do
        include Functional::Memo

        class << self
          attr_accessor :count
        end

        self.count = 0

        def self.add(a, b)
          self.count += 1
          a + b
        end
        memoize :add

        def self.increment(n)
          self.count += 1
        end

        def self.exception(ex = StandardError)
          raise ex
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

      it 'raises an exception when the given method has already been memoized' do
        expect{
          subject.memoize(:add)
        }.to raise_error(ArgumentError)
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

      it 'works when included in a class' do
        subject = Class.new do
          include Functional::Memo
          class << self
            attr_accessor :count
          end
          self.count = 0
          def self.foo
            self.count += 1
          end
          memoize :foo
        end

        10.times{ subject.foo }
        expect(subject.count).to eq 1
      end

      it 'works when included in a module' do
        subject = Module.new do
          include Functional::Memo
          class << self
            attr_accessor :count
          end
          self.count = 0
          def self.foo
            self.count += 1
          end
          memoize :foo
        end

        10.times{ subject.foo }
        expect(subject.count).to eq 1
      end

      it 'works when extended by a module' do
        subject = Module.new do
          extend Functional::Memo
          class << self
            attr_accessor :count
          end
          self.count = 0
          def self.foo
            self.count += 1
          end
          memoize :foo
        end

        10.times{ subject.foo }
        expect(subject.count).to eq 1
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

      let(:memoizer_factory){ Functional::Memo::ClassMethods.const_get(:Memoizer) }
      let(:memoizer){ memoizer_factory.new(:func, 0) }

      before(:each) do
        allow(memoizer_factory).to receive(:new).with(any_args).and_return(memoizer)
      end

      it 'locks a mutex whenever a memoized function is called' do
        expect(memoizer).to receive(:synchronize).exactly(:once).with(no_args)

        subject.memoize(:increment)
        subject.increment(0)
      end

      it 'unlocks the mutex whenever a memoized function is called' do
        expect(memoizer).to receive(:synchronize).exactly(:once).with(no_args)

        subject.memoize(:increment)
        subject.increment(0)
      end

      it 'unlocks the mutex when the method call raises an exception' do
        expect(memoizer).to receive(:synchronize).exactly(:once).with(no_args)

        subject.memoize(:exception)
        begin
          subject.exception
        rescue
          # suppress
        end
      end

      it 'uses different mutexes for different functions' do
        expect(memoizer_factory).to receive(:new).with(any_args).exactly(3).times.and_return(memoizer)
        # once for memoize(:add) in the definition
        subject.memoize(:increment)
        subject.memoize(:exception)
      end
    end
  end
end
