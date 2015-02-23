require 'ostruct'

module Functional

  describe ValueStruct do

    context 'instanciation' do

      specify 'raises an exception when no arguments given' do
        expect {
          ValueStruct.new
        }.to raise_error(ArgumentError)
      end

      specify 'with a hash sets fields using has values' do
        subject = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')
        expect(subject.foo).to eq 1
        expect(subject.bar).to eq :two
        expect(subject.baz).to eq 'three'
      end

      specify 'with a hash creates true predicates for has keys' do
        subject = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')
        expect(subject.foo?).to be true
        expect(subject.bar?).to be true
        expect(subject.baz?).to be true
      end

      specify 'can be created from any object that responds to #each_pair' do
        clazz = Class.new do
          def each_pair(&block)
            {answer: 42, harmless: 'mostly'}.each_pair(&block)
          end
        end
        struct = clazz.new
        subject = ValueStruct.new(struct)
        expect(subject.answer).to eq 42
        expect(subject.harmless).to eq 'mostly'
      end

      specify 'raises an exception if given a non-hash argument' do
        expect {
          ValueStruct.new(:bogus)
        }.to raise_error(ArgumentError)
      end
    end

    context 'set fields' do

      subject { ValueStruct.new(foo: 42, bar: "Don't Panic") }

      specify 'have a reader which returns the value' do
        expect(subject.foo).to eq 42
        expect(subject.bar).to eq "Don't Panic"
      end

      specify 'have a predicate which returns true' do
        expect(subject.foo?).to be true
        expect(subject.bar?).to be true
      end
    end

    context 'unset fields' do

      subject { ValueStruct.new(foo: 42, bar: "Don't Panic") }

      specify 'have a magic predicate that always returns false' do
        expect(subject.baz?).to be false
      end
    end

    context 'accessors' do

      let!(:field_value_pairs) { {foo: 1, bar: :two, baz: 'three'} }

      subject { ValueStruct.new(field_value_pairs) }

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

      specify '#set? returns false for an unset field' do
        expect(subject.set?(:harmless)).to be false
      end

      specify '#set? returns true for a field that has been set' do
        subject = ValueStruct.new(harmless: 'mostly')
        expect(subject.set?(:harmless)).to be true
      end

      specify '#fetch gets the value of a set field' do
        subject = ValueStruct.new(harmless: 'mostly')
        expect(subject.fetch(:harmless, 'extremely')).to eq 'mostly'
      end

      specify '#fetch returns the given value when the field is unset' do
        expect(subject.fetch(:harmless, 'extremely')).to eq 'extremely'
      end

      specify '#fetch does not set an unset field' do
        subject.fetch(:answer, 42)
        expect {
          subject.answer
        }.to raise_error(NoMethodError)
      end

      specify '#to_h returns the key/value pairs for all set values' do
        subject = ValueStruct.new(field_value_pairs)
        expect(subject.to_h).to eq field_value_pairs
        expect(subject.to_h).to_not be_frozen
      end

      specify '#each_pair returns an Enumerable when no block given' do
        subject = ValueStruct.new(field_value_pairs)
        expect(subject.each_pair).to be_a Enumerable
      end

      specify '#each_pair enumerates over each field/value pair' do
        subject = ValueStruct.new(field_value_pairs)
        result = {}

        subject.each_pair do |field, value|
          result[field] = value
        end

        expect(result).to eq field_value_pairs
      end
    end

    context 'reflection' do

      specify '#eql? returns true when both define the same fields with the same values' do
        first = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')
        second = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')

        expect(first.eql?(second)).to be true
        expect(first == second).to be true
      end

      specify '#eql? returns false when other has different fields defined' do
        first = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')
        second = ValueStruct.new(foo: 1, 'bar' => :two)

        expect(first.eql?(second)).to be false
        expect(first == second).to be false
      end

      specify '#eql? returns false when other has different field values' do
        first = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')
        second = ValueStruct.new(foo: 1, 'bar' => :two, baz: 3)

        expect(first.eql?(second)).to be false
        expect(first == second).to be false
      end

      specify '#eql? returns false when other is not a ValueStruct' do
        attributes = {answer: 42, harmless: 'mostly'}
        clazz = Class.new do
          def to_h; {answer: 42, harmless: 'mostly'}; end
        end

        other = clazz.new
        subject = ValueStruct.new(attributes)

        expect(subject.eql?(other)).to be false
        expect(subject == other).to be false
      end

      specify '#inspect begins with the class name' do
        subject = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')
        expect(subject.inspect).to match(/^#<#{described_class}\s+/)
      end

      specify '#inspect includes all field/value pairs' do
        field_value_pairs = {foo: 1, 'bar' => :two, baz: 'three'}
        subject = ValueStruct.new(field_value_pairs)

        field_value_pairs.each do |field, value|
          expect(subject.inspect).to match(/:#{field}=>"?:?#{value}"?/)
        end
      end

      specify '#to_s returns the same value as #inspect' do
        subject = ValueStruct.new(foo: 1, 'bar' => :two, baz: 'three')
        expect(subject.to_s).to eq subject.inspect
      end
    end
  end
end
