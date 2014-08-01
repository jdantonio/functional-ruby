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

    specify 'the "try" writer sets the new value when unset' do
      subject.try_bar(42)
      expect(subject.bar).to eq 42
    end

    specify 'the "try setter does not change the value once set"' do
      subject.bar = 42
      subject.try_bar('Boom!')
      expect(subject.bar).to eq 42
    end

    specify 'the "try" writer returns true when it sets the value' do
      expect(subject.try_bar(42)).to be true
    end

    specify 'the "try" writer returns false when the value was already set' do
      subject.bar = 42
      expect(subject.try_bar('Boom!')).to be false
    end

    specify 'accepts multiple attribute names on one call' do
      clazz = Class.new do
        include Functional::Final
        final_attribute :foo, :bar, :baz
      end

      subject = clazz.new

      expect(subject.foo?).to be false
      expect(subject.bar?).to be false
      expect(subject.baz?).to be false
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
  end
end
