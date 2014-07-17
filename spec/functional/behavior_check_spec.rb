require 'spec_helper'

#Functional::BehaviorInfo :gen_foo do
  #method :foo # any arity
  #method :bar, 2
  #method :baz, -2
  #class_method :foo # any arity
  #class_method :bar, 2
  #class_method :baz, -2
#end

#behavior_info = Functional::BehaviorInfo(:gen_foo)

#class MyClass
  #include Functional::BehaviorCheck

  #def do_stuff(first, second)
    #BehaveAs? first, :foobar
    #BehaveAs! second, :gen_foo
    #BehaviorDefined? :foobar
    #BehaviorDefined! :gen_foo
  #end
#end

#class ThisClass
  #Functional::Behavior :gen_foo
#end

#class ThisModule
  #Functional::Behavior :gen_foo
#end

#Functional::BehaviorCheck::BehaveAs? ThisClass, :foobar
#Functional::BehaviorCheck::BehaveAs! ThisModule, :gen_foo

#Functional::BehaviorCheck::BehaviorDefined? :foobar
#Functional::BehaviorCheck::BehaviorDefined! :gen_foo

describe 'behavior specification' do

  before(:each) do
    @behavior_info = Functional::BehaviorCheck.class_variable_get(:@@info)
    Functional::BehaviorCheck.class_variable_set(:@@info, {})
  end

  after(:each) do
    Functional::BehaviorCheck.class_variable_set(:@@info, @behavior_info)
  end

  context 'BehaviorInfo method' do

    context 'without a block' do

      it 'returns the specified behavior when defined' do
        Functional::BehaviorInfo(:foo){ nil }
        expect(Functional::BehaviorInfo(:foo)).to_not be_nil
      end

      it 'returns nil when not defined' do
        expect(Functional::BehaviorInfo(:foo)).to be_nil
      end
    end

    context 'with a block' do

      it 'raises an exception if the behavior has already been specified' do
        Functional::BehaviorInfo(:foo){ nil }

        expect {
          Functional::BehaviorInfo(:foo){ nil }
        }.to raise_error(Functional::BehaviorError)
      end

      it 'specifies an instance method with any arity' do
        Functional::BehaviorInfo :foo do
          method :foo
        end

        info = Functional::BehaviorInfo(:foo)
        expect(info[:methods][:foo]).to be_nil
      end

      it 'specifies an instance method with a given arity' do
        Functional::BehaviorInfo :foo do
          method :foo, 2
        end

        info = Functional::BehaviorInfo(:foo)
        expect(info[:methods][:foo]).to eq 2
      end

      it 'specifies a class method with any arity' do
        Functional::BehaviorInfo :foo do
          class_method :foo
        end

        info = Functional::BehaviorInfo(:foo)
        expect(info[:class_methods][:foo]).to be_nil
      end

      it 'specifies a class method with a given arity' do
        Functional::BehaviorInfo :foo do
          class_method :foo, 2
        end

        info = Functional::BehaviorInfo(:foo)
        expect(info[:class_methods][:foo]).to eq 2
      end
    end
  end

  describe Functional::BehaviorCheck do

    context 'BehaveAs?' do

      it 'validates methods with no parameters' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, 0)
          class_method(:baz, 0)
        end

        clazz = Class.new do
          def bar(); nil; end
          def self.baz(); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be true
      end

      it 'validates methods with a fixed number of parameters' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, 3)
          class_method(:baz, 3)
        end

        clazz = Class.new do
          def bar(a,b,c); nil; end
          def self.baz(a,b,c); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be true
      end

      it 'validates methods with optional parameters' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, -2)
          class_method(:baz, -2)
        end

        clazz = Class.new do
          def bar(a, b=1); nil; end
          def self.baz(a, b=1, c=2); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be true
      end

      if RUBY_VERSION >= '2.0'
        it 'validates methods with keyword parameters' do
          Functional::BehaviorInfo(:foo) do
            method(:bar, -2)
            class_method(:baz, -3)
          end

          clazz = Class.new do
            def bar(a, foo: 'foo', baz: 'baz'); nil; end
            def self.baz(a, b, foo: 'foo', baz: 'baz'); nil; end
          end

          expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be true
        end
      end

      it 'validates methods with variable length argument lists' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, -2)
          class_method(:baz, -3)
        end

        clazz = Class.new do
          def bar(a, *args); nil; end
          def self.baz(a, b, *args); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be true
      end

      it 'validates methods with arity -1' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, -1)
          class_method(:baz, -1)
        end

        clazz = Class.new do
          def bar(*args); nil; end
          def self.baz(*args); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be true
      end

      it 'validates classes' do
        Functional::BehaviorInfo(:foo) do
          class_method(:baz, -3)
        end

        clazz = Class.new do
          def self.baz(a, b, *args); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz, :foo)).to be true
      end

      it 'validates modules' do
        Functional::BehaviorInfo(:foo) do
          class_method(:baz, -3)
        end

        clazz = Module.new do
          def bar(a, *args); nil; end
          def self.baz(a, b, *args); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz, :foo)).to be true
      end

      it 'always accepts methods when arity not given' do
        Functional::BehaviorInfo(:foo) do
          method(:foo)
          method(:bar)
          method(:baz)
          class_method(:foo)
          class_method(:bar)
          class_method(:baz)
        end

        clazz = Class.new do
          def foo(); nil; end
          def bar(a, b, c); nil; end
          def baz(a, b, *args); nil; end
          def self.foo(); nil; end
          def self.bar(a, b, c); nil; end
          def self.baz(a, b, *args); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be true
      end

      it 'accepts and checks multiple behaviors' do
        Functional::BehaviorInfo(:foo){ method(:foo) }
        Functional::BehaviorInfo(:bar){ method(:foo) }
        Functional::BehaviorInfo(:baz){ method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo, :bar, :baz)
        ).to be true
      end

      it 'returns false if one or more instance methods do not match' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be false
      end

      it 'returns false if one or more class methods do not match' do
        Functional::BehaviorInfo(:foo) do
          class_method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect(Functional::BehaviorCheck::BehaveAs?(clazz.new, :foo)).to be false
      end

      it 'returns false if one or more behaviors has not been defined' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, 0)
          class_method(:bar, 0)
        end

        expect(
          Functional::BehaviorCheck::BehaveAs?('object', :foo, :bar)
        ).to be false
      end
    end

    context 'BehaveAs!' do

      it 'returns the target on success' do
        Functional::BehaviorInfo(:foo) do
          method(:foo)
          method(:bar)
          method(:baz)
          class_method(:foo)
          class_method(:bar)
          class_method(:baz)
        end

        clazz = Class.new do
          def foo(); nil; end
          def bar(a, b, c); nil; end
          def baz(a, b, *args); nil; end
          def self.foo(); nil; end
          def self.bar(a, b, c); nil; end
          def self.baz(a, b, *args); nil; end
        end

        target = clazz.new
        expect(Functional::BehaviorCheck::BehaveAs!(target, :foo)).to eq target
      end

      it 'raises an exception if one or more instance methods do not match' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect{
          Functional::BehaviorCheck::BehaveAs!(clazz.new, :foo)
        }.to raise_error(Functional::BehaviorError)
      end

      it 'raises an exception if one or more class methods do not match' do
        Functional::BehaviorInfo(:foo) do
          class_method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect{
          Functional::BehaviorCheck::BehaveAs!(clazz.new, :foo)
        }.to raise_error(Functional::BehaviorError)
      end

      it 'raises an exception if one or more behaviors has not been defined' do
        Functional::BehaviorInfo(:foo) do
          method(:bar, 0)
          class_method(:bar, 0)
        end

        expect{
          Functional::BehaviorCheck::BehaveAs!('object', :foo)
        }.to raise_error(Functional::BehaviorError)
      end
    end

    context 'BehaviorDefined?' do
      pending
    end

    context 'BehaviorDefined!' do
      pending
    end
  end
end
