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
      }.should raise_error(ArgumentError)
    end
  end

end
