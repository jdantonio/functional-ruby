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
      expect($__behavior_info__.keys.first).to eq :gen_foo
    end

    it 'accepts a string name' do
      behavior_info('gen_foo', foo: 0)
      expect($__behavior_info__.keys.first).to eq :gen_foo
    end

    it 'accepts zero function names' do
      behavior_info(:gen_foo)
      expect($__behavior_info__.keys.first).to eq :gen_foo
    end

    it 'accepts symbols for function names' do
      behavior_info(:gen_foo, foo: 0)
      expect($__behavior_info__.values.first).to eq({foo: 0})
    end

    it 'accepts strings as function names' do
      behavior_info(:gen_foo, 'foo' => 0)
      expect($__behavior_info__.values.first).to eq({foo: 0})
    end

    it 'accepts numeric arity values' do
      behavior_info(:gen_foo, foo: 0)
      expect($__behavior_info__.values.first).to eq({foo: 0})
    end

    it 'accepts :any as an arity value' do
      behavior_info(:gen_foo, foo: :any)
      expect($__behavior_info__.values.first).to eq({foo: :any})
    end
  end

  context 'behavior/1' do

    it 'raises an exception if the behavior has not been defined' do
      expect {
        Class.new{
          behavior(:gen_foo)
        }
      }.to raise_error(Functional::BehaviorError)
    end

    it 'can be called multiple times for one class' do
      behavior_info(:gen_foo, foo: 0)
      behavior_info(:gen_bar, bar: 0)

      expect {
        Class.new{
          behavior(:gen_foo)
          behavior(:gen_bar)
        }
      }.not_to raise_error
    end
  end

  context 'object creation' do

    before(:all) do
      @behavior_check = Functional.configuration.behavior_check_on_construction?
      Functional.configure do |config|
        config.behavior_check_on_construction = true
      end
    end

    after(:all) do
      Functional.configure do |config|
        config.behavior_check_on_construction = @behavior_check
      end
    end

    it 'checks all required behaviors' do
      behavior_info(:gen_foo, foo: 0)
      behavior_info(:gen_bar, bar: 1)

      clazz = Class.new {
        behavior(:gen_foo)
        behavior(:gen_bar)
        def foo() nil; end
      }
      expect{ clazz.new }.to raise_error(Functional::BehaviorError)

      clazz = Class.new {
        behavior(:gen_foo)
        behavior(:gen_bar)
        def bar() nil; end
      }
      expect{ clazz.new }.to raise_error(Functional::BehaviorError)

      clazz = Class.new {
        behavior(:gen_foo)
        behavior(:gen_bar)
      }
      expect{ clazz.new }.to raise_error(Functional::BehaviorError)
    end

    it 'allows constructor check to be permanently disabled when gem loaded' do

      starting_config = Functional.configuration.behavior_check_on_construction?

      behavior_info(:gen_foo, foo: 0)

      Functional.configure do |config|
        config.behavior_check_on_construction = true
      end
      clazz = Class.new { behavior(:gen_foo) }
      expect { clazz.new }.to raise_error(Functional::BehaviorError)

      Functional.configure do |config|
        config.behavior_check_on_construction = false
      end
      clazz = Class.new { behavior(:gen_foo) }
      expect { clazz.new }.not_to raise_error()

      Functional.configure do |config|
        config.behavior_check_on_construction = starting_config
      end
    end

    context 'instance methods' do

      it 'raises an exception when one or more function definitions are missing' do
        behavior_info(:gen_foo, foo: 0, bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo() nil; end
        }

        expect {
          clazz.new
        }.to raise_error(Functional::BehaviorError)
      end

      it 'raises an exception when one or more functions do not have proper arity' do
        behavior_info(:gen_foo, foo: 0)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo(broken) nil; end
        }

        expect {
          clazz.new
        }.to raise_error(Functional::BehaviorError)
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, foo: :any)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo(first) nil; end
        }

        expect {
          clazz.new
        }.not_to raise_error
      end

      it 'creates the object when function definitions match' do
        behavior_info(:gen_foo, foo: 0, bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def foo() nil; end
          def bar(first) nil; end
        }

        expect {
          clazz.new
        }.not_to raise_error
      end
    end

    context 'class methods' do

      it 'raises an exception when one or more function definitions are missing' do
        behavior_info(:gen_foo, self_foo: 0, self_bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo() nil; end
        }

        expect {
          clazz.new
        }.to raise_error(Functional::BehaviorError)
      end

      it 'raises an exception when one or more functions do not have proper arity' do
        behavior_info(:gen_foo, self_foo: 0)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo(broken) nil; end
        }

        expect {
          clazz.new
        }.to raise_error(Functional::BehaviorError)
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, self_foo: :any)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo(first) nil; end
        }

        expect {
          clazz.new
        }.not_to raise_error
      end

      it 'creates the object when function definitions match' do
        behavior_info(:gen_foo, self_foo: 0, self_bar: 1)
        clazz = Class.new {
          behavior(:gen_foo)
          def self.foo() nil; end
          def self.bar(first) nil; end
        }

        expect {
          clazz.new
        }.not_to raise_error
      end
    end

    context 'inheritance' do

      it 'raises an exception if a superclass includes a behavior the subclass does not support' do
        behavior_info(:gen_foo, foo: 0)
        superclass = Class.new{
          behavior(:gen_foo)
        }
        subclass = Class.new(superclass)

        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)
      end

      it 'raises an exception if a module includes a behavior the containing class does not support' do
        behavior_info(:gen_foo, foo: 0)
        mod = Module.new{
          behavior(:gen_foo)
        }
        subclass = Class.new{
          include mod
        }

        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)
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
        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)

        subclass = Class.new(superclass){
          behavior(:gen_baz)
          def foo() nil; end
          def baz() nil; end
        }
        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)

        subclass = Class.new(superclass){
          behavior(:gen_baz)
          def foo() nil; end
          def bar() nil; end
        }
        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)

        subclass = Class.new(superclass){
          behavior(:gen_baz)
          def foo() nil; end
          def bar() nil; end
          def baz() nil; end
        }
        expect {
          subclass.new
        }.not_to raise_error
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
        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)

        subclass = Class.new{
          include mod
          def foo() nil; end
          def baz() nil; end
        }
        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)

        subclass = Class.new{
          include mod
          def foo() nil; end
          def bar() nil; end
        }
        expect {
          subclass.new
        }.to raise_error(Functional::BehaviorError)

        subclass = Class.new{
          include mod
          def foo() nil; end
          def bar() nil; end
          def baz() nil; end
        }
        expect {
          subclass.new
        }.not_to raise_error
      end
    end
  end

  context '#behaves_as?' do

    it 'returns false when the behavior does not exist' do
      clazz = Class.new { }
      expect(clazz.new.behaves_as?(:gen_foo)).to be false
    end

    it 'accepts behavior name as a symbol' do
      behavior_info(:gen_foo)
      clazz = Class.new { }
      expect(clazz.new.behaves_as?(:gen_foo)).to be true
    end

    it 'accepts behavior name as a string' do
      behavior_info(:gen_foo)
      clazz = Class.new { }
      expect(clazz.new.behaves_as?('gen_foo')).to be true
    end

    context 'Object' do

      it 'returns true when the behavior is fully suported' do
        behavior_info(:gen_foo, foo: 0, bar: 1, baz: 2)
        clazz = Class.new {
          def foo() nil; end
          def bar(first) nil; end
          def baz(first, second) nil; end
        }

        expect(clazz.new.behaves_as?(:gen_foo)).to be true
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, foo: :any)
        clazz = Class.new {
          def foo(*args, &block) nil; end
        }

        expect(clazz.new.behaves_as?(:gen_foo)).to be true
      end

      it 'returns false when the behavior is partially supported' do
        behavior_info(:gen_foo, foo: 0, bar: 1, baz: 2)
        clazz = Class.new {
          def foo() nil; end
          def bar(first) nil; end
        }

        expect(clazz.new.behaves_as?(:gen_foo)).to be false
      end

      it 'returns false when the behavior is not supported at all' do
        behavior_info(:gen_foo, foo: 0, bar: 1, baz: 2)
        clazz = Class.new { }
        expect(clazz.new.behaves_as?(:gen_foo)).to be false
      end

      it 'raises an exception on failure when abend is true' do
        behavior_info(:gen_foo, foo: 0)
        behavior_info(:gen_bar, self_bar: 1)
        behavior_info(:gen_baz, baz: :any)
        clazz = Class.new { }

        expect {
          clazz.new.behaves_as?(:gen_foo, true)
        }.to raise_error(Functional::BehaviorError)

        expect {
          clazz.new.behaves_as?(:gen_bar, true)
        }.to raise_error(Functional::BehaviorError)

        expect {
          clazz.new.behaves_as?(:gen_baz, true)
        }.to raise_error(Functional::BehaviorError)
      end

      it 'exception includes the name and arity of the first missing function' do
        behavior_info(:gen_foo, foo: 0)
        behavior_info(:gen_bar, self_bar: 1)
        behavior_info(:gen_baz, baz: :any)
        clazz = Class.new { }

        begin
          clazz.new.behaves_as?(:gen_foo, true)
        rescue Functional::BehaviorError => ex
          expect(ex.message).to match(/foo\/0/)
        end

        begin
          clazz.new.behaves_as?(:gen_bar, true)
        rescue Functional::BehaviorError => ex
          expect(ex.message).to match(/#self\.bar\/1/)
        end

        begin
          clazz.new.behaves_as?(:gen_baz, true)
        rescue Functional::BehaviorError => ex
          expect(ex.message).to match(/#baz\/:any/)
        end
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

        expect(clazz.behaves_as?(:gen_foo)).to be true
        expect(clazz.new.behaves_as?(:gen_foo)).to be true
      end

      it 'accepts any arity when function arity is set to :any' do
        behavior_info(:gen_foo, self_foo: :any)
        clazz = Class.new {
          def self.foo(*args, &block) nil; end
        }

        expect(clazz.behaves_as?(:gen_foo)).to be true
        expect(clazz.new.behaves_as?(:gen_foo)).to be true
      end

      it 'returns false when the behavior is partially supported' do
        behavior_info(:gen_foo, self_foo: 0, bar: 1, self_baz: 2)
        clazz = Class.new {
          def self.foo() nil; end
          def self(first) nil; end
        }

        expect(clazz.behaves_as?(:gen_foo)).to be false
        expect(clazz.new.behaves_as?(:gen_foo)).to be false
      end

      it 'returns false when the behavior is not supported at all' do
        behavior_info(:gen_foo, self_foo: 0, self_bar: 1, self_baz: 2)
        clazz = Class.new { }
        expect(clazz.new.behaves_as?(:gen_foo)).to be false
      end
    end
  end

  context 'aliases' do

    it 'aliases behaviour_info for behavior_info' do
      behaviour_info(:gen_foo)
      clazz = Class.new { }
      expect(clazz.new.behaves_as?(:gen_foo)).to be true
    end

    it 'aliases interface for behavior_info' do
      interface(:gen_foo)
      clazz = Class.new { }
      expect(clazz.new.behaves_as?(:gen_foo)).to be true
    end

    it 'aliases behaviour for behavior' do
      behavior_info(:gen_foo, foo: 0)
      clazz = Class.new {
        behaviour(:gen_foo)
        def foo() nil; end
      }
      expect(clazz.new.behaves_as?(:gen_foo)).to be true
    end

    it 'aliases behaves_as for behavior' do
      behavior_info(:gen_foo, foo: 0)
      clazz = Class.new {
        behaves_as :gen_foo
        def foo() nil; end
      }
      expect(clazz.new.behaves_as?(:gen_foo)).to be true
    end
  end
end
