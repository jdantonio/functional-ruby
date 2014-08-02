require 'spec_helper'

module Functional

  describe Final do

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
      }.to raise_error(Functional::FinalityError)
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
