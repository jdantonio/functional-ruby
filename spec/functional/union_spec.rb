require 'spec_helper'
require_relative 'abstract_struct_shared'

module Functional

  describe Union do

    let!(:expected_members){ [:a, :b, :c] }
    let!(:expected_values){ [42, nil, nil] }

    let(:struct_class) { Union.new(*expected_members) }
    let(:struct_object) { struct_class.send(struct_class::MEMBERS.first, 42) }

    it_should_behave_like :abstract_struct

    context 'factories' do

      specify 'exist for each member' do
        expected_members.each do |member|
          expect(struct_class).to respond_to(member)
        end
      end

      specify 'require a value' do
        expected_members.each do |member|
          expect(struct_class.method(member).arity).to eq 1
        end
      end

      specify 'set the member appropriately' do
        clazz = Union.new(:foo, :bar)
        obj = clazz.foo(10)
        expect(obj.member).to eq :foo
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

      specify '#member returns the appropriate member' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).member).to eq :foo
      end

      specify '#value returns the appropriate member' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).value).to eq 10
      end

      specify 'return the appropriate value for the set member' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).foo).to eq 10
      end

      specify 'return nil for the unset member' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.foo(10).bar).to be_nil
        expect(clazz.foo(10).baz).to be_nil
      end
    end

    context 'predicates' do

      specify 'exist for each member' do
        expected_members.each do |member|
          predicate = "#{member}?".to_sym
          expect(struct_object).to respond_to(predicate)
          expect(struct_object.method(predicate).arity).to eq 0
        end
      end

      specify 'return true for the set member' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).foo?).to be true
      end

      specify 'return false for the unset members' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.foo(10).bar?).to be false
        expect(clazz.foo(10).baz?).to be false
      end
    end
  end
end
