require 'spec_helper'

module Functional

  describe Union do

    let!(:expected){ [:a, :b, :c] }

    let(:union_class) { Union.new(*expected) }
    let(:union_object) { union_class.send(union_class.formats.first, 0) }

    context 'format collection' do

      it 'contains all possible formats' do
        expected.each do |format|
          expect(union_class.formats).to include(format)
        end
      end

      it 'is frozen' do
        expect(union_class.formats).to be_frozen
      end

      it 'does not overwrite formats for other unions' do
        expect(union_class.formats).to_not eq AbstractUnion.formats

        tester = Union.new(*[:foo, union_class.formats, :bar].flatten)
        expect(union_class.formats).to_not eq tester.formats
      end

      it 'is the same when called on the class and on an object' do
        expect(union_class.formats).to eq union_object.formats
      end
    end

    context 'factories' do

      specify 'exist for each format' do
        expected.each do |format|
          expect(union_class).to respond_to(format)
        end
      end

      specify 'require a value' do
        expected.each do |format|
          expect(union_class.method(format).arity).to eq 1
        end
      end

      specify 'set the format appropriately' do
        clazz = Union.new(:foo, :bar)
        obj = clazz.foo(10)
        expect(obj.format).to eq :foo
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

      specify '#format returns the appropriate format' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).format).to eq :foo
      end

      specify '#value returns the appropriate format' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).value).to eq 10
      end

      specify 'exist for each format' do
        expected.each do |format|
          expect(union_object).to respond_to(format)
          expect(union_object.method(format).arity).to eq 0
        end
      end

      specify 'return the appropriate value for the set format' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).foo).to eq 10
      end

      specify 'return nil for the unset format' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.foo(10).bar).to be_nil
        expect(clazz.foo(10).baz).to be_nil
      end
    end

    context 'predicates' do

      specify 'exist for each format' do
        expected.each do |format|
          predicate = "#{format}?".to_sym
          expect(union_object).to respond_to(predicate)
          expect(union_object.method(predicate).arity).to eq 0
        end
      end

      specify 'return true for the set format' do
        clazz = Union.new(:foo, :bar)
        expect(clazz.foo(10).foo?).to be true
      end

      specify 'return false for the unset formats' do
        clazz = Union.new(:foo, :bar, :baz)
        expect(clazz.foo(10).bar?).to be false
        expect(clazz.foo(10).baz?).to be false
      end
    end

    context 'enumeration' do

      specify '#each with a block iterates over all formats and values' do
        clazz = Union.new(:foo, :bar, :baz)
        obj = clazz.foo(10)
        state = {}
        obj.each do |format, value|
          state[format] = value
        end

        expect(state[:foo]).to eq 10
        expect(state[:bar]).to be_nil
        expect(state[:baz]).to be_nil
      end

      specify '#each without a block returns an Enumerable' do
        clazz = Union.new(:foo, :bar, :baz)
        obj = clazz.foo(10)
        expect(obj.each).to be_a Enumerable
      end
    end

    context 'reflection' do

      specify '#to_h returns a Hash with all format/value pairs' do
        clazz = Union.new(:foo, :bar, :baz)

        foo = clazz.foo(10)
        bar = clazz.bar(true)
        baz = clazz.baz("VHT")

        expect(foo.to_h).to eq(foo: 10, bar: nil, baz: nil)
        expect(bar.to_h).to eq(foo: nil, bar: true, baz: nil)
        expect(baz.to_h).to eq(foo: nil, bar: nil, baz: "VHT")
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

      specify '#inspect includes all format/value pairs' do
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
    end
  end
end
