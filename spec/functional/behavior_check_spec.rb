require 'spec_helper'

Functional::BehaviorInfo :gen_foo do
  method :foo # any arity
  method :bar, 2
  method :baz, -2
  class_method :foo # any arity
  class_method :bar, 2
  class_method :baz, -2
  constant :foo
  constant :baz_bar
end

behavior_info = Functional::BehaviorInfo(:gen_foo)

class MyClass
  include Functional::BehaviorCheck

  def do_stuff(first, second)
    BehaveAs? first, :foobar
    BehaveAs! second, :gen_foo
    BehaviorDefined? :foobar
    BehaviorDefined! :gen_foo
  end
end

class ThisClass
  Functional::Behavior :gen_foo
end

class ThisModule
  Functional::Behavior :gen_foo
end

Functional::BehaveAs? ThisClass, :foobar
Functional::BehaveAs! ThisModule, :gen_foo

Functional::BehaviorDefined? :foobar
Functional::BehaviorDefined! :gen_foo

module Functional

  describe 'BehaviorInfo' do
    pending
  end

  describe 'Behavior' do
    pending
  end

  describe 'BehaveAs?' do
    pending
  end

  describe 'BehavesAs!' do
    pending
  end

  describe 'BehaviorDefined?' do
    pending
  end

  describe 'BehaviorDefined!' do
    pending
  end

  describe BehaviorCheck do

    before(:each) do
      @behavior_info = BehaviorCheck.class_variable_get(:@@info)
      BehaviorCheck.class_variable_set(:@@info, {})
    end

    after(:each) do
      BehaviorCheck.class_variable_set(:@@info, @behavior_info)
    end


    context 'BehaveAs?' do
      pending
    end

    context 'BehavesAs!' do
      pending
    end

    context 'BehaviorDefined?' do
      pending
    end

    context 'BehaviorDefined!' do
      pending
    end
  end
end
