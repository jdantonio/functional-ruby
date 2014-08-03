require 'spec_helper'
require 'ostruct'

module Functional

  describe FinalStruct do

    context 'instanciation' do

      specify 'with no args defines no fields' do
        subject = FinalStruct.new
        expect(subject.to_h).to be_empty
      end

      specify 'with a hash defines fields for hash keys' do
        subject = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        expect(subject).to respond_to(:foo)
        expect(subject).to respond_to(:bar)
        expect(subject).to respond_to(:baz)
      end

      specify 'with a hash sets fields using has values' do
        subject = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        expect(subject.foo).to eq 1
        expect(subject.bar).to eq :two
        expect(subject.baz).to eq 'three'
      end

      specify 'with a hash creates true predicates for has keys' do
        subject = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        expect(subject).to be_foo
        expect(subject).to be_bar
        expect(subject).to be_baz
      end

      specify 'can be created from any object that responds to #to_h' do
        clazz = Class.new do
          def to_h; {answer: 42, harmless: 'mostly'}; end
        end
        struct = clazz.new
        subject = FinalStruct.new(struct)
        expect(subject.answer).to eq 42
        expect(subject.harmless).to eq 'mostly'
      end

      specify 'raises an exception if given a non-hash argument' do
        expect {
          FinalStruct.new(:bogus)
        }.to raise_error(ArgumentError)
      end
    end

    context 'set fields' do

      subject do
        struct = FinalStruct.new
        struct.foo = 42
        struct.bar = "Don't Panic"
        struct
      end

      specify 'have a reader which returns the value' do
        expect(subject.foo).to eq 42
        expect(subject.bar).to eq "Don't Panic"
      end

      specify 'have a predicate which returns true' do
        expect(subject).to be_foo
        expect(subject).to be_bar
      end

      specify 'raise an exception when written to again' do
        expect {subject.foo = 0}.to raise_error(Functional::FinalityError)
        expect {subject.bar = 0}.to raise_error(Functional::FinalityError)
      end
    end

    context 'unset fields' do

      subject { FinalStruct.new }

      specify 'have a magic reader that always returns nil' do
        expect(subject.foo).to be nil
        expect(subject.bar).to be nil
        expect(subject.baz).to be nil
      end

      specify 'have a magic predicate that always returns false' do
        expect(subject.foo?).to be false
        expect(subject.bar?).to be false
        expect(subject.baz?).to be false
      end

      specify 'have a magic writer that sets the field' do
        expect(subject.foo = 42).to eq 42
        expect(subject.bar = :towel).to eq :towel
        expect(subject.baz = "Don't Panic").to eq "Don't Panic"
      end
    end

    context 'accessors' do

      let!(:field_value_pairs) { {foo: 1, bar: :two, baz: 'three'} }

      subject { FinalStruct.new(field_value_pairs) }

      specify '#get returns the value of a set field' do
        expect(subject.get(:foo)).to eq 1
      end

      specify '#get returns nil for an unset field' do
        expect(subject.get(:bogus)).to be nil
      end

      specify '#[] is an alias for #get' do
        expect(subject[:foo]).to eq 1
        expect(subject[:bogus]).to be nil
      end

      specify '#set sets the value of an unset field' do
        subject.set(:harmless, 'mostly')
        expect(subject.harmless).to eq 'mostly'
        expect(subject).to be_harmless
      end

      specify '#set raises an exception if the field has already been set' do
        subject.set(:harmless, 'mostly')
        expect {
          subject.set(:harmless, 'extremely')
        }.to raise_error(Functional::FinalityError)
      end

      specify '#[]= is an alias for set' do
        subject[:harmless] = 'mostly'
        expect(subject.harmless).to eq 'mostly'
        expect {
          subject[:harmless] = 'extremely'
        }.to raise_error(Functional::FinalityError)
      end

      specify '#get_or_set returns the value of a set field' do
        subject.answer = 42
        expect(subject.get_or_set(:answer, 100)).to eq 42
      end

      specify '#get_or_set sets the value of an unset field' do
        subject.get_or_set(:answer, 42)
        expect(subject.answer).to eq 42
        expect(subject).to be_answer
      end

      specify '#get_or_set returns the value of a newly set field' do
        expect(subject.get_or_set(:answer, 42)).to eq 42
      end

      specify '#fetch gets the value of a set field' do
        subject.harmless = 'mostly'
        expect(subject.fetch(:harmless, 'extremely')).to eq 'mostly'
      end

      specify '#fetch returns the given value when the field is unset' do
        expect(subject.fetch(:harmless, 'extremely')).to eq 'extremely'
      end

      specify '#fetch does not set an unset field' do
        subject.fetch(:answer, 42)
        expect(subject.answer).to be_nil
        expect(subject.answer?).to be false
      end

      specify '#to_h returns the key/value pairs for all set values' do
        subject = FinalStruct.new(field_value_pairs)
        expect(subject.to_h).to eq field_value_pairs
      end

      specify '#to_h is updated when new fields are added' do
        subject = FinalStruct.new
        field_value_pairs.each_pair do |field, value|
          subject.set(field, value)
        end
        expect(subject.to_h).to eq field_value_pairs
      end

      specify '#each_pair returns an Enumerable when no block given' do
        subject = FinalStruct.new(field_value_pairs)
        expect(subject.each_pair).to be_a Enumerable
      end

      specify '#each_pair enumerates over each field/value pair' do
        subject = FinalStruct.new(field_value_pairs)
        result = {}

        subject.each_pair do |field, value|
          result[field] = value
        end

        expect(result).to eq field_value_pairs
      end
    end

    context 'reflection' do

      specify '#eql? returns true when both define the same fields with the same values' do
        first = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        second = FinalStruct.new(foo: 1, bar: :two, baz: 'three')

        expect(first.eql?(second)).to be true
        expect(first == second).to be true
      end

      specify '#eql? returns false when other has different fields defined' do
        first = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        second = FinalStruct.new(foo: 1, bar: :two)

        expect(first.eql?(second)).to be false
        expect(first == second).to be false
      end

      specify '#eql? returns false when other has different field values' do
        first = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        second = FinalStruct.new(foo: 1, bar: :two, baz: 3)

        expect(first.eql?(second)).to be false
        expect(first == second).to be false
      end

      specify '#eql? returns false when other is not a FinalStruct' do
        attributes = {answer: 42, harmless: 'mostly'}
        clazz = Class.new do
          def to_h; {answer: 42, harmless: 'mostly'}; end
        end
        other = clazz.new
        subject = FinalStruct.new(attributes)
        expect(subject.eql?(other)).to be false
        expect(subject == other).to be false
      end

      specify '#inspect begins with the class name' do
        subject = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        expect(subject.inspect).to match(/^#<#{described_class}\s+/)
      end

      specify '#inspect includes all field/value pairs' do
        field_value_pairs = {foo: 1, bar: :two, baz: 'three'}
        subject = FinalStruct.new(field_value_pairs)

        field_value_pairs.each do |field, value|
          expect(subject.inspect).to match(/:#{field}=>"?:?#{value}"?/)
        end
      end

      specify '#to_s returns the same value as #inspect' do
        subject = FinalStruct.new(foo: 1, bar: :two, baz: 'three')
        expect(subject.to_s).to eq subject.inspect
      end

      specify '#method_missing raises an exception for methods with unrecognized signatures' do
        expect {
          subject.foo(1, 2, 3)
        }.to raise_error(NoMethodError)
      end
    end
  end
end
