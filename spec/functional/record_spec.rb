require 'spec_helper'
require_relative 'abstract_struct_shared'

module Functional

  describe Record do

    let!(:expected_fields){ [:a, :b, :c] }
    let!(:expected_values){ [42, nil, nil] }

    let(:struct_class) { Record.new(*expected_fields) }
    let(:struct_object) { struct_class.new(struct_class.fields.first => 42) }

    it_should_behave_like :abstract_struct

    context 'definition' do

      it 'default all fields values to nil' do
        fields = [:foo, :bar, :baz]
        clazz = Record.new(*fields)
        
        record = clazz.new

        fields.each do |field|
          expect(record.send(field)).to be_nil
        end
      end

      it 'sets initial values based on values given at object construction' do
        clazz = Record.new(:foo, :bar, :baz)
        record = clazz.new(foo: 1, bar: 2, baz: 3)

        expect(record.foo).to eq 1
        expect(record.bar).to eq 2
        expect(record.baz).to eq 3
      end

      it 'defaults fields to values given during class creation' do
        clazz = Record.new(:foo, :bar, :baz) do
          default :foo, 42
          default :bar, 'w00t!'
        end

        record = clazz.new
        expect(record.foo).to eq 42
        expect(record.bar).to eq 'w00t!'
        expect(record.baz).to be_nil
      end

      it 'overrides default values with values provided at object construction' do
        clazz = Record.new(:foo, :bar, :baz) do
          default :foo, 42
          default :bar, 'w00t!'
          default :baz, :bogus
        end

        record = clazz.new(foo: 1, bar: 2)

        expect(record.foo).to eq 1
        expect(record.bar).to eq 2
        expect(record.baz).to eq :bogus
      end

      it 'does not conflate defaults across record classes' do
        clazz_foo = Record.new(:foo, :bar, :baz) do
          default :foo, 42
        end

        clazz_matz = Record.new(:foo, :bar, :baz) do
          default :foo, 'Matsumoto'
        end

        expect(clazz_foo.new.foo).to eq 42
        expect(clazz_matz.new.foo).to eq 'Matsumoto'
      end

      it 'raises an exception when values for requred field are not provided' do
        clazz = Record.new(:foo, :bar, :baz) do
          mandatory :foo
        end

        expect {
          clazz.new(bar: 1)
        }.to raise_exception(ArgumentError)
      end

      it 'raises an exception when required values are nil' do
        clazz = Record.new(:foo, :bar, :baz) do
          mandatory :foo
        end

        expect {
          clazz.new(foo: nil, bar: 1)
        }.to raise_exception(ArgumentError)
      end

      it 'allows a field to be required and have a default value' do
        clazz = Record.new(:foo, :bar, :baz) do
          mandatory :foo
          default :foo, 42
        end

        expect {
          clazz.new
        }.to_not raise_exception

        expect(clazz.new.foo).to eq 42
      end

      it 'allows multiple required fields to be specified together' do
        clazz = Record.new(:foo, :bar, :baz) do
          mandatory :foo, :bar, :baz
        end

        expect {
          clazz.new(foo: 1, bar: 2)
        }.to raise_exception(ArgumentError)

        expect {
          clazz.new(bar: 2, baz: 3)
        }.to raise_exception(ArgumentError)

        expect {
          clazz.new(foo: 1, bar: 2, baz: 3)
        }.to_not raise_exception
      end

      it 'raises an exception if the default value for a require field is nil' do
        clazz = Record.new(:foo, :bar, :baz) do
          mandatory :foo
          default :foo, nil
        end

        expect {
          clazz.new
        }.to raise_exception(ArgumentError)
      end

      it 'does not conflate default values across record classes' do
        clazz_foo = Record.new(:foo, :bar, :baz) do
          mandatory :foo
        end

        clazz_baz = Record.new(:foo, :bar, :baz) do
          mandatory :baz
        end

        expect {
          clazz_foo.new(foo: 42)
        }.to_not raise_error

        expect {
          clazz_baz.new(baz: 42)
        }.to_not raise_error
      end
    end
  end
end
