require 'spec_helper'

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
      pending
    end

    it 'matches a number argument' do
      pending
    end

    it 'matches a string argument' do
      pending
    end

    it 'matches a array argument' do
      pending
    end

    it 'matches a hash argument' do
      pending
    end

    it 'matches a object argument' do
      pending
    end

    it 'matches a variable argument' do
      pending
    end
  end

end
