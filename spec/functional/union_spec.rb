require 'spec_helper'
require_relative 'abstract_struct_shared'

module Functional

  describe Union do

    let!(:expected_fields){ [:a, :b, :c] }
    let!(:expected_values){ [42, nil, nil] }

    let(:struct_class) { Union.new(*expected_fields) }
    let(:struct_object) { struct_class.send(struct_class.fields.first, 42) }

    it_should_behave_like :abstract_struct

    context 'factories' do

      specify 'exist for each field' do
        expected_fields.each do |field|
          expect(struct_class).to respond_to(field)
        end
      end

      specify 'require a value' do
        expected_fields.each do |field|
          expect(struct_class.method(field).arity).to eq 1
        end
      end

      specify 'set the field appropriately' do
        clazz = Union.new(:foo, :bar)
        obj = clazz.foo(10)
        expect(obj.field).to eq :foo
      end

      specify 'set the value appropriately' do
        clazz = Union.new(:foo, :bar)
        obj = clazz.foo(10)
        expect(obj.value).to eq 10
      end

      specify 'return a frozen union' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10)).to be_frozen
      end

      specify 'force #new to be private' do
        clazz = Union.new(:foo, :bar)
        expect {
          clazz.new
        }.to raise_error(NoMethodError)
      end
    end

    context 'readers' do

      specify '#field returns the appropriate field' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).field).to eq :foo
      end

      specify '#value returns the appropriate field' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).value).to eq 10
      end

      specify 'return the appropriate value for the set field' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).foo).to eq 10
      end

      specify 'return nil for the unset field' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.foo(10).bar).to be_nil
        expect(clazz.foo(10).baz).to be_nil
      end
    end

    context 'predicates' do

      specify 'exist for each field' do
        expected_fields.each do |field|
          predicate = "#{field}?".to_sym
          expect(struct_object).to respond_to(predicate)
          expect(struct_object.method(predicate).arity).to eq 0
        end
      end

      specify 'return true for the set field' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).foo?).to be true
      end

      specify 'return false for the unset fields' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.foo(10).bar?).to be false
        expect(clazz.foo(10).baz?).to be false
      end
    end
  end
end
