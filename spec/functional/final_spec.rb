require 'spec_helper'

module Functional

  describe Final do

    #class Foo
    #  include Functional::Final
    #  final_attribute :bar
    #end

    #foo = Foo.new
    #foo.bar      #=> nil
    #foo.bar?     #=> false
    #foo.bar = 42 #=> 42
    #foo.bar      #=> 42
    #foo.bar?     #=> true
    #foo.bar = 10 #=> Functional::ImmutablityError

    let(:clazz) do
      Class.new do
        include Functional::Final
        final_attribute :bar
      end
    end

    subject { clazz.new }

    specify 'attribute reader returns nil before set' do
      expect(subject.bar).to be nil
    end

    specify 'attribute predicate returns false before set' do
      expect(subject.bar?).to be false
    end

    specify 'setting the attribute returns the new value' do
      result = ->{ subject.bar = 42 }.call
      expect(result).to eq 42
    end

    specify 'attribute reader returns the value once set' do
      subject.bar = 42
      expect(subject.bar).to eq 42
    end

    specify 'attribute predicate returns true once set' do
      subject.bar = 42
      expect(subject.bar?).to be true
    end

    specify 'setting the attribute more than once raises an exception' do
      subject.bar = 42
      expect {
        subject.bar = 42
      }.to raise_error(Functional::ImmutablityError)
    end

    specify 'setting the attribute on one instance does not affect other instances' do
      f1 = clazz.new
      f2 = clazz.new

      f1.bar = 42

      expect(f1.bar).to eq 42
      expect(f2.bar).to be nil

      expect(f1.bar?).to be true
      expect(f2.bar?).to be false

      f2.bar = 'Boom!'

      expect(f1.bar).to eq 42
      expect(f2.bar).to eq 'Boom!'

      expect(f1.bar?).to be true
      expect(f2.bar?).to be true
    end

    context 'thread safety' do

      let(:safe_clazz) do
        Class.new do
          include Functional::Final
          final_attribute :bar
          def initialize
            thread_safe_final
          end
        end
      end

      let(:mutex){ Mutex.new }

      before(:each) do
        allow(Mutex).to receive(:new).with(no_args).and_return(mutex)
        allow(mutex).to receive(:unlock).with(no_args)
      end

      subject { safe_clazz.new }

      it 'does not normally create a mutex' do
        expect(Mutex).to_not receive(:new).with(any_args)
        subject = clazz.new
      end

      it 'creates a mutex when #thread_safe_final is called' do
        expect(Mutex).to receive(:new).with(no_args).and_return(mutex)
        subject
      end

      it 'locks the writer method when #thread_safe_final' do
        expect(mutex).to receive(:try_lock).with(no_args).and_return(true)
        subject.bar = 42
      end

      it 'raises an exception on writing if the mutex is locked' do
        allow(mutex).to receive(:try_lock).with(no_args).and_return(false)
        expect {
          subject.bar = 42
        }.to raise_error(Functional::ImmutablityError)
      end
    end
  end
end
