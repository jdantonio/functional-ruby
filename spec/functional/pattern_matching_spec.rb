require 'ostruct'

module Functional

  describe PatternMatching do

    def new_clazz(&block)
      clazz = Class.new
      clazz.send(:include, PatternMatching)
      clazz.instance_eval(&block) if block_given?
      return clazz
    end

    subject { new_clazz }

    context '#defn declaration' do

      it 'can be used within a class declaration' do
        expect {
          class Clazz
            include PatternMatching
            defn(:foo){}
          end
        }.not_to raise_error
      end

      it 'can be used on a class object' do
        expect {
          clazz = Class.new
          clazz.send(:include, PatternMatching)
          clazz.defn(:foo){}
        }.not_to raise_error
      end

      it 'requires a block' do
        expect {
          clazz = Class.new
          clazz.send(:include, PatternMatching)
          clazz.defn(:foo)
        }.to raise_error(ArgumentError)
      end
    end

    context 'constructor' do

      it 'can pattern match the constructor' do

        unless RUBY_VERSION == '1.9.2'
          subject.defn(:initialize, PatternMatching::UNBOUND, PatternMatching::UNBOUND, PatternMatching::UNBOUND) { 'three args' }
          subject.defn(:initialize, PatternMatching::UNBOUND, PatternMatching::UNBOUND) { 'two args' }
          subject.defn(:initialize, PatternMatching::UNBOUND) { 'one arg' }

          expect { subject.new(1) }.not_to raise_error
          expect { subject.new(1, 2) }.not_to raise_error
          expect { subject.new(1, 2, 3) }.not_to raise_error
          expect { subject.new(1, 2, 3, 4) }.to raise_error
        end
      end
    end

    context 'parameter count' do

      it 'does not match a call with not enough arguments' do

        subject.defn(:foo, true) { 'expected' }

        expect {
          subject.new.foo()
        }.to raise_error(NoMethodError)
      end

      it 'does not match a call with too many arguments' do

        subject.defn(:foo, true) { 'expected' }

        expect {
          subject.new.foo(true, false)
        }.to raise_error(NoMethodError)
      end

    end

    context 'recursion' do

      it 'defers unmatched calls to the superclass' do

        class UnmatchedCallTesterSuperclass
          def foo(bar)
            return bar
          end
        end

        class UnmatchedCallTesterSubclass < UnmatchedCallTesterSuperclass
          include PatternMatching
          defn(:foo) { 'baz' }
        end

        subject = UnmatchedCallTesterSubclass.new
        expect(subject.foo(:bar)).to eq :bar
      end

      it 'can call another match from within a match' do

        subject.defn(:foo, :bar) { |arg| foo(:baz) }
        subject.defn(:foo, :baz) { |arg| 'expected' }

        expect(subject.new.foo(:bar)).to eq 'expected'
      end

      it 'can call a superclass method from within a match' do

        class RecursiveCallTesterSuperclass
          def foo(bar)
            return bar
          end
        end

        class RecursiveCallTesterSubclass < RecursiveCallTesterSuperclass
          include PatternMatching
          defn(:foo, :bar) { foo(:baz) }
        end

        subject = RecursiveCallTesterSubclass.new
        expect(subject.foo(:bar)).to eq :baz
      end
    end

    context 'datatypes' do

      it 'matches an argument of the class given in the match parameter' do

        subject.defn(:foo, Integer) { 'expected' }
        expect(subject.new.foo(100)).to eq 'expected'

        expect {
          subject.new.foo('hello')
        }.to raise_error(NoMethodError)
      end

      it 'passes the matched argument to the block' do

        subject.defn(:foo, Integer) { |arg| arg }
        expect(subject.new.foo(100)).to eq 100
      end
    end

    context 'function with no parameters' do

      it 'accepts no parameters' do

        subject.defn(:foo){}
        obj = subject.new

        expect {
          obj.foo
        }.not_to raise_error
      end

      it 'does not accept any parameters' do

        subject.defn(:foo){}
        obj = subject.new

        expect {
          obj.foo(1)
        }.to raise_error(NoMethodError)
      end

      it 'returns the correct value' do
        subject.defn(:foo){ true }
        expect(subject.new.foo).to be true
      end
    end

    context 'function with one parameter' do

      it 'matches a nil parameter' do

        subject.defn(:foo, nil) { 'expected' }
        expect(subject.new.foo(nil)).to eq 'expected'

        expect {
          subject.new.foo('no match should be found')
        }.to raise_error(NoMethodError)
      end

      it 'matches a boolean parameter' do

        subject.defn(:foo, true) { 'expected' }
        subject.defn(:foo, false) { 'false case' }

        expect(subject.new.foo(true)).to eq 'expected'
        expect(subject.new.foo(false)).to eq 'false case'

        expect {
          subject.new.foo('no match should be found')
        }.to raise_error(NoMethodError)
      end

      it 'matches a symbol parameter' do

        subject.defn(:foo, :bar) { 'expected' }
        expect(subject.new.foo(:bar)).to eq 'expected'

        expect {
          subject.new.foo(:baz)
        }.to raise_error(NoMethodError)
      end

      it 'matches a number parameter' do

        subject.defn(:foo, 10) { 'expected' }
        expect(subject.new.foo(10)).to eq 'expected'

        expect {
          subject.new.foo(11.0)
        }.to raise_error(NoMethodError)
      end

      it 'matches a string parameter' do

        subject.defn(:foo, 'bar') { 'expected' }
        expect(subject.new.foo('bar')).to eq 'expected'

        expect {
          subject.new.foo('baz')
        }.to raise_error(NoMethodError)
      end

      it 'matches an array parameter' do

        subject.defn(:foo, [1, 2, 3]) { 'expected' }
        expect(subject.new.foo([1, 2, 3])).to eq 'expected'

        expect {
          subject.new.foo([3, 4, 5])
        }.to raise_error(NoMethodError)
      end

      it 'matches a hash parameter' do

        subject.defn(:foo, bar: 1, baz: 2) { 'expected' }
        expect(subject.new.foo(bar: 1, baz: 2)).to eq 'expected'

        expect {
          subject.new.foo(foo: 0, bar: 1)
        }.to raise_error(NoMethodError)
      end

      it 'matches an object parameter' do

        subject.defn(:foo, OpenStruct.new(foo: :bar)) { 'expected' }
        expect(subject.new.foo(OpenStruct.new(foo: :bar))).to eq 'expected'

        expect {
          subject.new.foo(OpenStruct.new(bar: :baz))
        }.to raise_error(NoMethodError)
      end

      it 'matches an unbound parameter' do

        subject.defn(:foo, PatternMatching::UNBOUND) {|arg| arg }
        expect(subject.new.foo(:foo)).to eq :foo
      end
    end

    context 'function with two parameters' do

      it 'matches two bound arguments' do

        subject.defn(:foo, :male, :female){ 'expected' }
        expect(subject.new.foo(:male, :female)).to eq 'expected'

        expect {
          subject.new.foo(1, 2)
        }.to raise_error(NoMethodError)
      end

      it 'matches two unbound arguments' do

        subject.defn(:foo, PatternMatching::UNBOUND, PatternMatching::UNBOUND) do |first, second|
          [first, second]
        end
        expect(subject.new.foo(:male, :female)).to eq [:male, :female]
      end

      it 'matches when the first argument is bound and the second is not' do

        subject.defn(:foo, :male, PatternMatching::UNBOUND) do |second|
          second
        end
        expect(subject.new.foo(:male, :female)).to eq :female
      end

      it 'matches when the second argument is bound and the first is not' do

        subject.defn(:foo, PatternMatching::UNBOUND, :female) do |first|
          first
        end
        expect(subject.new.foo(:male, :female)).to eq :male
      end
    end

    context 'functions with hash arguments' do

      it 'matches an empty argument hash with an empty parameter hash' do

        subject.defn(:foo, {}) { true }
        expect(subject.new.foo({})).to be true

        expect {
          subject.new.foo({one: :two})
        }.to raise_error(NoMethodError)
      end

      it 'matches when all hash keys and values match' do

        subject.defn(:foo, {bar: :baz}) { true }
        expect(subject.new.foo(bar: :baz)).to be true

        expect {
          subject.new.foo({one: :two})
        }.to raise_error(NoMethodError)
      end

      it 'matches when every pattern key/value are in the argument' do

        subject.defn(:foo, {bar: :baz}) { true }
        expect(subject.new.foo(foo: :bar, bar: :baz)).to be true
      end

      it 'matches when all keys with unbound values in the pattern have an argument' do

        subject.defn(:foo, {bar: PatternMatching::UNBOUND}) { true }
        expect(subject.new.foo(bar: :baz)).to be true
      end

      it 'passes unbound values to the block' do

        subject.defn(:foo, {bar: PatternMatching::UNBOUND}) {|arg| arg }
        expect(subject.new.foo(bar: :baz)).to eq :baz
      end

      it 'passes the matched hash to the block' do

        subject.defn(:foo, {bar: :baz}) { |opts| opts }
        expect(subject.new.foo(bar: :baz)).to eq({bar: :baz})
      end

      it 'does not match a non-hash argument' do

        subject.defn(:foo, {}) { true }

        expect {
          subject.new.foo(:bar)
        }.to raise_error(NoMethodError)
      end

      it 'supports idiomatic has-as-last-argument syntax' do

        subject.defn(:foo, PatternMatching::UNBOUND) { |opts| opts }
        expect(subject.new.foo(bar: :baz, one: 1, many: 2)).to eq({bar: :baz, one: 1, many: 2})
      end
    end

    context 'varaible-length argument lists' do

      it 'supports ALL as the last parameter' do

        subject.defn(:foo, 1, 2, PatternMatching::ALL) { |args| args }
        expect(subject.new.foo(1, 2, 3)).to eq([3])
        expect(subject.new.foo(1, 2, :foo, :bar)).to eq([:foo, :bar])
        expect(subject.new.foo(1, 2, :foo, :bar, one: 1, two: 2)).to eq([:foo, :bar, {one: 1, two: 2}])
      end
    end

    context 'guard clauses' do

      it 'matches when the guard clause returns true' do

        subject.defn(:old_enough, PatternMatching::UNBOUND){
          true
        }.when{|x| x > 16 }

        expect(subject.new.old_enough(20)).to be true
      end

      it 'does not match when the guard clause returns false' do

        subject.defn(:old_enough, PatternMatching::UNBOUND){
          true
        }.when{|x| x > 16 }

        expect {
          subject.new.old_enough(10)
        }.to raise_error(NoMethodError)
      end

      it 'continues pattern matching when the guard clause returns false' do

        subject.defn(:old_enough, PatternMatching::UNBOUND){
          true
        }.when{|x| x > 16 }

        subject.defn(:old_enough, PatternMatching::UNBOUND) { false }

        expect(subject.new.old_enough(10)).to be false
      end

      it 'raises an exception when the guard clause does not have a block' do

        expect {
          subject.defn(:initialize, PatternMatching::UNBOUND) { 'one arg' }.when
        }.to raise_error(ArgumentError)
      end
    end
  end
end
