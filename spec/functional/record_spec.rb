require 'spec_helper'
require_relative 'abstract_struct_shared'

module Functional

  describe Record do

    let!(:expected_members){ [:a, :b, :c] }
    let!(:expected_values){ [42, nil, nil] }

    let(:struct_class) { Record.new(*expected_members) }
    let(:struct_object) { struct_class.new(struct_class.members.first => 42) }

    it_should_behave_like :abstract_struct

    context 'definition' do

      it 'default all members values to nil' do
        members = [:foo, :bar, :baz]
        clazz = Record.new(*members)
        
        record = clazz.new

        members.each do |member|
          expect(record.send(member)).to be_nil
        end
      end

      it 'sets initial values based on values given at object construction' do
        clazz = Record.new(:foo, :bar, :baz)
        record = clazz.new(foo: 1, bar: 2, baz: 3)

        expect(record.foo).to eq 1
        expect(record.bar).to eq 2
        expect(record.baz).to eq 3
      end

      it 'defaults members to values given during class creation' do
        clazz = Record.new(:foo, :bar, :baz) do
          self.foo = 42
          self.bar = 'w00t!'
        end

        expect(clazz.new.foo).to eq 42
        expect(clazz.new.bar).to eq 'w00t!'
        expect(clazz.new.foo).to be_nil
      end

      it 'overrides default values with values provided at object construction' do
        clazz = Record.new(:foo, :bar, :baz) do
          self.foo = 42
          self.bar = 'w00t!'
          self.baz = :bogus
        end

        record = clazz.new(foo: 1, bar: 2)

        expect(record.foo).to eq 1
        expect(record.bar).to eq 2
        expect(record.baz).to eq :bogus
      end

      it 'does not conflate defaults across record classes' do
        clazz_foo = Record.new(:foo, :bar, :baz) do
          self.foo = 42
        end

        clazz_matz = Record.new(:foo, :bar, :baz) do
          self.foo = 'Matsumoto'
        end

        expect(clazz_foo.new.foo).to eq 42
        expect(clazz_matz.new.foo).to eq 'Matsumoto'
      end
    end
  end
end
