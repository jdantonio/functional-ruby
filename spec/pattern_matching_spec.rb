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
          defn :foo
        end
      }.should_not raise_error
    end

    it 'can be used on a class object' do
      lambda {
        clazz = Class.new
        clazz.send(:include, PatternMatching)
        clazz.defn(:foo)
      }.should_not raise_error
    end

    it 'defers unmatched calls to the superclass' do
      
      class UnmatchedCallTesterSuperclass
        def foo(bar)
          return bar
        end
      end

      class UnmatchedCallTesterSubclass  < UnmatchedCallTesterSuperclass
        include PatternMatching
        defn(:foo) { 'baz' }
      end

      subject = UnmatchedCallTesterSubclass.new
      subject.foo(:bar).should eq :bar
    end
  end

  context 'function with no parameters' do

    it 'accepts no parameters' do

      subject.defn(:foo)
      obj = subject.new

      lambda {
        obj.foo
      }.should_not raise_error(NoMethodError)
    end

    it 'does not accept any parameters' do

      subject.defn(:foo)
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
    
    it 'matches a boolean argument' do

      subject.defn(:foo, true) { 'true case' }
      subject.defn(:foo, false) { 'false case' }

      subject.new.foo(true).should eq 'true case'
      subject.new.foo(false).should eq 'false case'

      lambda {
        subject.new.foo('no match should be found')
      }.should raise_error(NoMethodError)
    end

    it 'matches a symbol argument' do

      subject.defn(:foo, :bar) { 'true case' }
      subject.new.foo(:bar).should eq 'true case'

      lambda {
        subject.new.foo(:baz)
      }.should raise_error(NoMethodError)
    end

    it 'matches a number argument' do

      subject.defn(:foo, 10) { 'true case' }
      subject.new.foo(10).should eq 'true case'

      lambda {
        subject.new.foo(11.0)
      }.should raise_error(NoMethodError)
    end

    it 'matches a string argument' do

      subject.defn(:foo, 'bar') { 'true case' }
      subject.new.foo('bar').should eq 'true case'

      lambda {
        subject.new.foo('baz')
      }.should raise_error(NoMethodError)
    end

    it 'matches an array argument' do

      subject.defn(:foo, [1, 2, 3]) { 'true case' }
      subject.new.foo([1, 2, 3]).should eq 'true case'

      lambda {
        subject.new.foo([3, 4, 5])
      }.should raise_error(NoMethodError)
    end

    it 'matches a hash argument' do

      subject.defn(:foo, bar: 1, baz: 2) { 'true case' }
      subject.new.foo(bar: 1, baz: 2).should eq 'true case'

      lambda {
        subject.new.foo(foo: 0, bar: 1, baz: 2)
      }.should raise_error(NoMethodError)
    end

    it 'matches an object argument' do

      subject.defn(:foo, OpenStruct.new(foo: :bar)) { 'true case' }
      subject.new.foo(OpenStruct.new(foo: :bar)).should eq 'true case'

      lambda {
        subject.new.foo(OpenStruct.new(bar: :baz))
      }.should raise_error(NoMethodError)
    end

    it 'matches a variable argument' do

      subject.defn(:foo, PatternMatching::UNBOUND) {|arg| arg }
      subject.new.foo(:foo).should eq :foo
    end
  end

  #class Foo
    #include PatternMatching
    #defn(:foo, _) { true }
  #end

end
