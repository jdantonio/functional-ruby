require 'spec_helper'
require 'ostruct'

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
      lambda {
        class Clazz
          include PatternMatching
          defn(:foo){}
        end
      }.should_not raise_error
    end

    it 'can be used on a class object' do
      lambda {
        clazz = Class.new
        clazz.send(:include, PatternMatching)
        clazz.defn(:foo){}
      }.should_not raise_error
    end

    it 'requires a block' do
      lambda {
        clazz = Class.new
        clazz.send(:include, PatternMatching)
        clazz.defn(:foo)
      }.should raise_error(ArgumentError)
    end
  end

  context 'constructor' do

    it 'can pattern match the constructor' do

      subject.defn(:initialize, PatternMatching::UNBOUND, PatternMatching::UNBOUND, PatternMatching::UNBOUND) { 'three args' }
      subject.defn(:initialize, PatternMatching::UNBOUND, PatternMatching::UNBOUND) { 'two args' }
      subject.defn(:initialize, PatternMatching::UNBOUND) { 'one arg' }

      lambda { subject.new(1) }.should_not raise_error
      lambda { subject.new(1, 2) }.should_not raise_error
      lambda { subject.new(1, 2, 3) }.should_not raise_error
      lambda { subject.new(1, 2, 3, 4) }.should raise_error
    end
  end

  context 'parameter count' do

    it 'does not match a call with not enough arguments' do

      subject.defn(:foo, true) { 'expected' }

      lambda {
        subject.new.foo()
      }.should raise_error(NoMethodError)
    end

    it 'does not match a call with too many arguments' do

      subject.defn(:foo, true) { 'expected' }

      lambda {
        subject.new.foo(true, false)
      }.should raise_error(NoMethodError)
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
      subject.foo(:bar).should eq :bar
    end

    it 'can call another match from within a match' do

      subject.defn(:foo, :bar) { |arg| foo(:baz) }
      subject.defn(:foo, :baz) { |arg| 'expected' }

      subject.new.foo(:bar).should eq 'expected'
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
      subject.foo(:bar).should eq :baz
    end
  end

  context 'datatypes' do

    it 'matches an argument of the class given in the match parameter' do

      subject.defn(:foo, Integer) { 'expected' }
      subject.new.foo(100).should eq 'expected'

      lambda {
        subject.new.foo('hello')
      }.should raise_error(NoMethodError)
    end

    it 'passes the matched argument to the block' do

      subject.defn(:foo, Integer) { |arg| arg }
      subject.new.foo(100).should eq 100
    end
  end

  context 'function with no parameters' do

    it 'accepts no parameters' do

      subject.defn(:foo){}
      obj = subject.new

      lambda {
        obj.foo
      }.should_not raise_error(NoMethodError)
    end

    it 'does not accept any parameters' do

      subject.defn(:foo){}
      obj = subject.new

      lambda {
        obj.foo(1)
      }.should raise_error(NoMethodError)
    end

    it 'returns the correct value' do
      subject.defn(:foo){ true }
      subject.new.foo.should be_true
    end
  end

  context 'function with one parameter' do

    it 'matches a nil parameter' do

      subject.defn(:foo, nil) { 'expected' }
      subject.new.foo(nil).should eq 'expected'

      lambda {
        subject.new.foo('no match should be found')
      }.should raise_error(NoMethodError)
    end

    it 'matches a boolean parameter' do

      subject.defn(:foo, true) { 'expected' }
      subject.defn(:foo, false) { 'false case' }

      subject.new.foo(true).should eq 'expected'
      subject.new.foo(false).should eq 'false case'

      lambda {
        subject.new.foo('no match should be found')
      }.should raise_error(NoMethodError)
    end

    it 'matches a symbol parameter' do

      subject.defn(:foo, :bar) { 'expected' }
      subject.new.foo(:bar).should eq 'expected'

      lambda {
        subject.new.foo(:baz)
      }.should raise_error(NoMethodError)
    end

    it 'matches a number parameter' do

      subject.defn(:foo, 10) { 'expected' }
      subject.new.foo(10).should eq 'expected'

      lambda {
        subject.new.foo(11.0)
      }.should raise_error(NoMethodError)
    end

    it 'matches a string parameter' do

      subject.defn(:foo, 'bar') { 'expected' }
      subject.new.foo('bar').should eq 'expected'

      lambda {
        subject.new.foo('baz')
      }.should raise_error(NoMethodError)
    end

    it 'matches an array parameter' do

      subject.defn(:foo, [1, 2, 3]) { 'expected' }
      subject.new.foo([1, 2, 3]).should eq 'expected'

      lambda {
        subject.new.foo([3, 4, 5])
      }.should raise_error(NoMethodError)
    end

    it 'matches a hash parameter' do

      subject.defn(:foo, bar: 1, baz: 2) { 'expected' }
      subject.new.foo(bar: 1, baz: 2).should eq 'expected'

      lambda {
        subject.new.foo(foo: 0, bar: 1)
      }.should raise_error(NoMethodError)
    end

    it 'matches an object parameter' do

      subject.defn(:foo, OpenStruct.new(foo: :bar)) { 'expected' }
      subject.new.foo(OpenStruct.new(foo: :bar)).should eq 'expected'

      lambda {
        subject.new.foo(OpenStruct.new(bar: :baz))
      }.should raise_error(NoMethodError)
    end

    it 'matches an unbound parameter' do

      subject.defn(:foo, PatternMatching::UNBOUND) {|arg| arg }
      subject.new.foo(:foo).should eq :foo
    end
  end

  context 'function with two parameters' do

    it 'matches two bound arguments' do

      subject.defn(:foo, :male, :female){ 'expected' }
      subject.new.foo(:male, :female).should eq 'expected'

      lambda {
        subject.new.foo(1, 2)
      }.should raise_error(NoMethodError)
    end

    it 'matches two unbound arguments' do

      subject.defn(:foo, PatternMatching::UNBOUND, PatternMatching::UNBOUND) do |first, second|
        [first, second]
      end
      subject.new.foo(:male, :female).should eq [:male, :female]
    end

    it 'matches when the first argument is bound and the second is not' do

      subject.defn(:foo, :male, PatternMatching::UNBOUND) do |second|
        second
      end
      subject.new.foo(:male, :female).should eq :female
    end

    it 'matches when the second argument is bound and the first is not' do

      subject.defn(:foo, PatternMatching::UNBOUND, :female) do |first|
        first
      end
      subject.new.foo(:male, :female).should eq :male
    end
  end

  context 'functions with hash arguments' do

    it 'matches an empty argument hash with an empty parameter hash' do

      subject.defn(:foo, {}) { true }
      subject.new.foo({}).should be_true

      lambda {
        subject.new.foo({one: :two})
      }.should raise_error(NoMethodError)
    end

    it 'matches when all hash keys and values match' do

      subject.defn(:foo, {bar: :baz}) { true }
      subject.new.foo(bar: :baz).should be_true

      lambda {
        subject.new.foo({one: :two})
      }.should raise_error(NoMethodError)
    end

    it 'matches when every pattern key/value are in the argument' do

      subject.defn(:foo, {bar: :baz}) { true }
      subject.new.foo(foo: :bar, bar: :baz).should be_true
    end

    it 'matches when all keys with unbound values in the pattern have an argument' do

      subject.defn(:foo, {bar: PatternMatching::UNBOUND}) { true }
      subject.new.foo(bar: :baz).should be_true
    end

    it 'passes unbound values to the block' do

      subject.defn(:foo, {bar: PatternMatching::UNBOUND}) {|arg| arg }
      subject.new.foo(bar: :baz).should eq :baz
    end

    it 'passes the matched hash to the block' do

      subject.defn(:foo, {bar: :baz}) { |opts| opts }
      subject.new.foo(bar: :baz).should == {bar: :baz}
    end

    it 'does not match a non-hash argument' do

      subject.defn(:foo, {}) { true }

      lambda {
        subject.new.foo(:bar)
      }.should raise_error(NoMethodError)
    end

    it 'supports idiomatic has-as-last-argument syntax' do

      subject.defn(:foo, PatternMatching::UNBOUND) { |opts| opts }
      subject.new.foo(bar: :baz, one: 1, many: 2).should == {bar: :baz, one: 1, many: 2}
    end
  end

  context 'varaible-length argument lists' do

    it 'supports ALL as the last parameter' do
      
      subject.defn(:foo, 1, 2, PatternMatching::ALL) { |args| args }
      subject.new.foo(1, 2, 3).should == [3]
      subject.new.foo(1, 2, :foo, :bar).should == [:foo, :bar]
      subject.new.foo(1, 2, :foo, :bar, one: 1, two: 2).should == [:foo, :bar, {one: 1, two: 2}]
    end
  end

  context 'guard clauses' do

    it 'matches when the guard clause returns true' do

      subject.defn(:old_enough, PatternMatching::UNBOUND){
        true
      }.when{|x| x > 16 }

      subject.new.old_enough(20).should be_true
    end

    it 'does not match when the guard clause returns false' do

      subject.defn(:old_enough, PatternMatching::UNBOUND){
        true
      }.when{|x| x > 16 }

      lambda {
        subject.new.old_enough(10)
      }.should raise_error(NoMethodError)
    end

    it 'continues pattern matching when the guard clause returns false' do

      subject.defn(:old_enough, PatternMatching::UNBOUND){
        true
      }.when{|x| x > 16 }

      subject.defn(:old_enough, PatternMatching::UNBOUND) { false }

      subject.new.old_enough(10).should be_false
    end

    it 'raises an exception when the guard clause does not have a block' do

      lambda {
        subject.defn(:foo).when
      }.should raise_error(ArgumentError)
    end

  end

end
