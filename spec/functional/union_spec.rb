require 'spec_helper'

module Functional

  describe Union do

    let!(:expected){ [:a, :b, :c] }

    let(:union_class) { Union.new(*expected) }
    let(:union_object) { union_class.send(union_class.members.first, 0) }

    context 'member collection' do

      it 'contains all possible members' do
        expected.each do |member|
          expect(union_class.members).to include(member)
        end
      end

      it 'is frozen' do
        expect(union_class.members).to be_frozen
      end

      it 'does not overwrite members for other unions' do
        expect(union_class.members).to_not eq AbstractUnion.members

        tester = Union.new(*[:foo, union_class.members, :bar].flatten)
        expect(union_class.members).to_not eq tester.members
      end

      it 'is the same when called on the class and on an object' do
        expect(union_class.members).to eq union_object.members
      end
    end

    context 'factories' do

      specify 'exist for each member' do
        expected.each do |member|
          expect(union_class).to respond_to(member)
        end
      end

      specify 'require a value' do
        expected.each do |member|
          expect(union_class.method(member).arity).to eq 1
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

      specify '#values returns all values in an array' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.bar(42).values).to eq [nil, 42, nil]
      end

      specify '#values is frozen' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.bar(42).values).to be_frozen
      end

      specify 'exist for each member' do
        expected.each do |member|
          expect(union_object).to respond_to(member)
          expect(union_object.method(member).arity).to eq 0
        end
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
        expected.each do |member|
          predicate = "#{member}?".to_sym
          expect(union_object).to respond_to(predicate)
          expect(union_object.method(predicate).arity).to eq 0
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

    context 'enumeration' do

      specify '#each_pair with a block iterates over all members and values' do
        clazz = Union.new(:foo, :bar, :baz)
        obj = clazz.foo(10)
        state = {}
        obj.each_pair do |member, value|
          state[member] = value
        end

        expect(state[:foo]).to eq 10
        expect(state[:bar]).to be_nil
        expect(state[:baz]).to be_nil
      end

      specify '#each_pair without a block returns an Enumerable' do
        clazz = Union.new(:foo, :bar, :baz)
        obj = clazz.foo(10)
        expect(obj.each_pair).to be_a Enumerable
      end

      specify '#each with a block iterates over all values' do
        clazz = Union.new(:foo, :bar, :baz)
        obj = clazz.foo(10)
        state = []
        obj.each do |value|
          state << value
        end

        expect(state[0]).to eq 10
        expect(state[1]).to be_nil
        expect(state[2]).to be_nil
      end

      specify '#each without a block returns an Enumerable' do
        clazz = Union.new(:foo, :bar, :baz)
        obj = clazz.foo(10)
        expect(obj.each).to be_a Enumerable
      end
    end

    context 'reflection' do

      specify 'asserts equality for two unions of the same class with equal values' do
        clazz = Union.new(:foo, :bar, :baz)

        foo = clazz.foo(10)
        bar = clazz.foo(10)

        expect(foo).to eq bar
        expect(foo).to eql bar
      end

      specify 'rejects equality for two unions of different classes' do
        clazz1 = Union.new(:foo, :bar, :baz)
        clazz2 = Union.new(:foo, :bar, :baz)

        foo = clazz1.foo(10)
        bar = clazz2.foo(10)

        expect(foo).to_not eq bar
        expect(foo).to_not eql bar
      end

      specify 'rejects equality for two unions of the same class with different values' do
        clazz = Union.new(:foo, :bar, :baz)

        foo = clazz.foo(10)
        bar = clazz.bar(10)

        expect(foo).to_not eq bar
        expect(foo).to_not eql bar
      end

      specify '#to_h returns a Hash with all member/value pairs' do
        clazz = Union.new(:foo, :bar, :baz)

        foo = clazz.foo(10)
        bar = clazz.bar(true)
        baz = clazz.baz("VHT")

        expect(foo.to_h).to eq(foo: 10, bar: nil, baz: nil)
        expect(bar.to_h).to eq(foo: nil, bar: true, baz: nil)
        expect(baz.to_h).to eq(foo: nil, bar: nil, baz: "VHT")
      end

      specify '#to_a retruns an Array with all values' do
        clazz = Union.new(:foo, :bar, :baz)

        foo = clazz.foo(10)
        bar = clazz.bar(true)
        baz = clazz.baz("VHT")

        expect(foo.to_a).to eq [10, nil, nil]
        expect(bar.to_a).to eq [nil, true, nil]
        expect(baz.to_a).to eq [nil, nil, "VHT"]
      end

      specify '#inspect begins with "#<union" and ends with ">"' do
        obj = Union.new(:foo, :bar, :baz).foo(10)
        expect(obj.inspect).to match(/^#<union /)
        expect(obj.inspect).to match(/>$/)
      end

      specify '#inspect includes the class name' do
        foo_class = Union.new(:foo)
        bar_class = Union.new(:bar)

        foo = foo_class.foo(0)
        bar = bar_class.bar(0)

        expect(foo.inspect).to match(/union #{foo_class.to_s}/)
        expect(bar.inspect).to match(/union #{bar_class.to_s}/)
      end

      specify '#inspect includes all member/value pairs' do
        clazz = Union.new(:foo, :bar, :baz)

        foo = clazz.foo(10)
        bar = clazz.bar(true)
        baz = clazz.baz("VHT")

        expect(foo.inspect).to match(/:foo=>10/)
        expect(foo.inspect).to match(/:bar=>nil/)
        expect(foo.inspect).to match(/:baz=>nil/)

        expect(bar.inspect).to match(/:foo=>nil/)
        expect(bar.inspect).to match(/:bar=>true/)
        expect(bar.inspect).to match(/:baz=>nil/)

        expect(baz.inspect).to match(/:foo=>nil/)
        expect(baz.inspect).to match(/:bar=>nil/)
        expect(baz.inspect).to match(/:baz=>"VHT"/)
      end

      specify '#inspect is aliased as #to_s' do
        object = Union.new(:foo, :bar, :baz).foo(42)
        expect(object.inspect).to eq object.to_s
      end

      specify '#length returns the number of members' do
        expect(Union.new(:foo).foo(0).length).to eq 1
        expect(Union.new(:foo, :bar).foo(0).length).to eq 2
        expect(Union.new(:foo, :bar, :baz).foo(0).length).to eq 3
      end

      specify 'aliases #length as #size' do
        expect(Union.new(:foo).foo(0).size).to eq 1
        expect(Union.new(:foo, :bar).foo(0).size).to eq 2
        expect(Union.new(:foo, :bar, :baz).foo(0).size).to eq 3
      end
    end
  end
end
