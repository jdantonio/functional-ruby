require 'spec_helper'

describe '-behavior' do

  before(:each) do
    @__behavior_info__ = $__behavior_info__
    $__behavior_info__ = {}
  end

  after(:each) do
    $__behavior_info__ = @__behavior_info__
  end

  context 'behavior_info/2' do

    it 'accepts a symbol name' do
      behavior_info(:gen_foo, foo: 0)
      $__behavior_info__.keys.first.should eq :gen_foo
    end

    it 'accepts a string name' do
      behavior_info('gen_foo', foo: 0)
      $__behavior_info__.keys.first.should eq :gen_foo
    end

    it 'accepts zero function names' do
      behavior_info(:gen_foo)
      $__behavior_info__.keys.first.should eq :gen_foo
    end

    it 'accepts symbols for function names' do
      behavior_info(:gen_foo, foo: 0)
      $__behavior_info__.values.first.should == {foo: 0}
    end

    it 'accepts strings as function names' do
      behavior_info(:gen_foo, 'foo' => 0)
      $__behavior_info__.values.first.should == {foo: 0}
    end

    it 'accepts numeric arity values' do
      behavior_info(:gen_foo, foo: 0)
      $__behavior_info__.values.first.should == {foo: 0}
    end

    it 'accepts :any as an arity value' do
      behavior_info(:gen_foo, foo: :any)
      $__behavior_info__.values.first.should == {foo: :any}
    end
  end

  context 'behavior/1' do

    it 'raises an exception if the behavior has not been defined' do
      lambda {
        Class.new{
          behavior(:gen_foo)
        }
      }.should raise_error(BehaviorError)
    end

    it 'can be called multiple times for one class' do
      behavior_info(:gen_foo, foo: 0)
      behavior_info(:gen_bar, bar: 0)

      lambda {
        Class.new{
          behavior(:gen_foo)
          behavior(:gen_bar)
        }
      }.should_not raise_error
    end
  end

  context 'object creation' do

    it 'checks all required behaviors' do
      behavior_info(:gen_foo, foo: 0)
      behavior_info(:gen_bar, bar: 1)

      clazz = Class.new {
        behavior(:gen_foo)
        behavior(:gen_bar)
        def foo() nil; end
      }
      lambda{ clazz.new }.should raise_error(BehaviorError)

      clazz = Class.new {
        behavior(:gen_foo)
        behavior(:gen_bar)
        def bar() nil; end
      }
      lambda{ clazz.new }.should raise_error(BehaviorError)

      clazz = Class.new {
        behavior(:gen_foo)
        behavior(:gen_bar)
      }
      lambda{ clazz.new }.should raise_error(BehaviorError)
    end

    context 'instance methods' do

      it 'raises an exception when one or more function definitions are missing' do
        behavior_info(:gen_foo, foo: 0, bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo() nil; end
        }

        lambda {
          clazz.new
        }.should raise_error(BehaviorError)
      end

      it 'raises an exception when one or more functions do not have proper arity' do
        behavior_info(:gen_foo, foo: 0)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo(broken) nil; end
        }

        lambda {
          clazz.new
        }.should raise_error(BehaviorError)
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, foo: :any)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo(first) nil; end
        }

        lambda {
          clazz.new
        }.should_not raise_error
      end

      it 'creates the object when function definitions match' do
        behavior_info(:gen_foo, foo: 0, bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo() nil; end
          def bar(first) nil; end
        }

        lambda {
          clazz.new
        }.should_not raise_error
      end
    end

    context 'class methods' do

      it 'raises an exception when one or more function definitions are missing' do
        behavior_info(:gen_foo, self_foo: 0, self_bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo() nil; end
        }

        lambda {
          clazz.new
        }.should raise_error(BehaviorError)
      end

      it 'raises an exception when one or more functions do not have proper arity' do
        behavior_info(:gen_foo, self_foo: 0)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo(broken) nil; end
        }

        lambda {
          clazz.new
        }.should raise_error(BehaviorError)
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, self_foo: :any)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo(first) nil; end
        }

        lambda {
          clazz.new
        }.should_not raise_error
      end

      it 'creates the object when function definitions match' do
        behavior_info(:gen_foo, self_foo: 0, self_bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo() nil; end
          def self.bar(first) nil; end
        }

        lambda {
          clazz.new
        }.should_not raise_error
      end
    end

    context 'inheritance' do

      it 'raises an exception if a superclass includes a behavior the subclass does not support' do
        behavior_info(:gen_foo, foo: 0)
        superclass = Class.new{
          behavior(:gen_foo)
        }
        subclass = Class.new(superclass)

        lambda {
          subclass.new
        }.should raise_error(BehaviorError)
      end

      it 'raises an exception if a module includes a behavior the containing class does not support' do
        behavior_info(:gen_foo, foo: 0)
        mod = Module.new{
          behavior(:gen_foo)
        }
        subclass = Class.new{
          include mod
        }

        lambda {
          subclass.new
        }.should raise_error(BehaviorError)
      end

      it 'supports behaviors from multiple ancestors' do
        behavior_info(:gen_foo, foo: 0)
        behavior_info(:gen_bar, bar: 0)
        behavior_info(:gen_baz, baz: 0)

        rootclass = Class.new{ behavior(:gen_foo) }
        superclass = Class.new(rootclass){ behavior(:gen_bar) }
        
        subclass = Class.new(superclass){
          behavior(:gen_baz)
          def bar() nil; end
          def baz() nil; end
        }
        lambda {
          subclass.new
        }.should raise_error(BehaviorError)

        subclass = Class.new(superclass){
          behavior(:gen_baz)
          def foo() nil; end
          def baz() nil; end
        }
        lambda {
          subclass.new
        }.should raise_error(BehaviorError)
        
        subclass = Class.new(superclass){
          behavior(:gen_baz)
          def foo() nil; end
          def bar() nil; end
        }
        lambda {
          subclass.new
        }.should raise_error(BehaviorError)
        
        subclass = Class.new(superclass){
          behavior(:gen_baz)
          def foo() nil; end
          def bar() nil; end
          def baz() nil; end
        }
        lambda {
          subclass.new
        }.should_not raise_error
      end

      it 'supports multiple behaviors in an included module' do
        behavior_info(:gen_foo, foo: 0)
        behavior_info(:gen_bar, bar: 0)
        behavior_info(:gen_baz, baz: 0)

        mod = Module.new{
          behavior(:gen_foo)
          behavior(:gen_bar)
          behavior(:gen_baz)
        }

        subclass = Class.new{
          include mod
          def bar() nil; end
          def baz() nil; end
        }
        lambda {
          subclass.new
        }.should raise_error(BehaviorError)

        subclass = Class.new{
          include mod
          def foo() nil; end
          def baz() nil; end
        }
        lambda {
          subclass.new
        }.should raise_error(BehaviorError)

        subclass = Class.new{
          include mod
          def foo() nil; end
          def bar() nil; end
        }
        lambda {
          subclass.new
        }.should raise_error(BehaviorError)

        subclass = Class.new{
          include mod
          def foo() nil; end
          def bar() nil; end
          def baz() nil; end
        }
        lambda {
          subclass.new
        }.should_not raise_error
      end
    end
  end

  context '#behaves_as?' do

    it 'returns false when the behavior does not exist' do
      clazz = Class.new { }
      clazz.new.behaves_as?(:gen_foo).should be_false
    end

    it 'accepts behavior name as a symbol' do
      behavior_info(:gen_foo)
      clazz = Class.new { }
      clazz.new.behaves_as?(:gen_foo).should be_true
    end

    it 'accepts behavior name as a string' do
      behavior_info(:gen_foo)
      clazz = Class.new { }
      clazz.new.behaves_as?('gen_foo').should be_true
    end

    context 'Object' do

      it 'returns true when the behavior is fully suported' do
        behavior_info(:gen_foo, foo: 0, bar: 1, baz: 2)
        clazz = Class.new {
          def foo() nil; end
          def bar(first) nil; end
          def baz(first, second) nil; end
        }

        clazz.new.behaves_as?(:gen_foo).should be_true
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, foo: :any)
        clazz = Class.new {
          def foo(*args, &block) nil; end
        }

        clazz.new.behaves_as?(:gen_foo).should be_true
      end

      it 'returns false when the behavior is partially supported' do
        behavior_info(:gen_foo, foo: 0, bar: 1, baz: 2)
        clazz = Class.new {
          def foo() nil; end
          def bar(first) nil; end
        }

        clazz.new.behaves_as?(:gen_foo).should be_false
      end

      it 'returns false when the behavior is not supported at all' do
        behavior_info(:gen_foo, foo: 0, bar: 1, baz: 2)
        clazz = Class.new { }
        clazz.new.behaves_as?(:gen_foo).should be_false
      end
    end

    context 'Class' do

      it 'returns true when the behavior is fully suported' do
        behavior_info(:gen_foo, self_foo: 0, self_bar: 1, baz: 2)
        clazz = Class.new {
          def self.foo() nil; end
          def self.bar(first) nil; end
          def baz(first, second) nil; end
        }

        clazz.behaves_as?(:gen_foo).should be_true
        clazz.new.behaves_as?(:gen_foo).should be_true
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, self_foo: :any)
        clazz = Class.new {
          def self.foo(*args, &block) nil; end
        }

        clazz.behaves_as?(:gen_foo).should be_true
        clazz.new.behaves_as?(:gen_foo).should be_true
      end

      it 'returns false when the behavior is partially supported' do
        behavior_info(:gen_foo, self_foo: 0, bar: 1, self_baz: 2)
        clazz = Class.new {
          def self.foo() nil; end
          def self(first) nil; end
        }

        clazz.behaves_as?(:gen_foo).should be_false
        clazz.new.behaves_as?(:gen_foo).should be_false
      end

      it 'returns false when the behavior is not supported at all' do
        behavior_info(:gen_foo, self_foo: 0, self_bar: 1, self_baz: 2)
        clazz = Class.new { }
        clazz.new.behaves_as?(:gen_foo).should be_false
      end
    end
  end

  context 'aliases' do

    it 'aliases behaviour_info for behavior_info' do
      behaviour_info(:gen_foo)
      clazz = Class.new { }
      clazz.new.behaves_as?(:gen_foo).should be_true
    end

    it 'aliases interface for behavior_info' do
      interface(:gen_foo)
      clazz = Class.new { }
      clazz.new.behaves_as?(:gen_foo).should be_true
    end

    it 'aliases behaviour for behavior' do
      behavior_info(:gen_foo, foo: 0)
      clazz = Class.new {
        behaviour(:gen_foo)
        def foo() nil; end
      }
      clazz.new.behaves_as?(:gen_foo).should be_true
    end

    it 'aliases behaves_as for behavior' do
      behavior_info(:gen_foo, foo: 0)
      clazz = Class.new {
        behaves_as :gen_foo
        def foo() nil; end
      }
      clazz.new.behaves_as?(:gen_foo).should be_true
    end
  end
end
