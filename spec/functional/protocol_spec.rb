require 'spec_helper'

describe 'protocol specification' do

  before(:each) do
    @protocol_info = Functional::ProtocolCheck.class_variable_get(:@@info)
    Functional::ProtocolCheck.class_variable_set(:@@info, {})
  end

  after(:each) do
    Functional::ProtocolCheck.class_variable_set(:@@info, @protocol_info)
  end

  context 'DefineProtocol method' do

    context 'without a block' do

      it 'returns the specified protocol when defined' do
        Functional::DefineProtocol(:foo){ nil }
        expect(Functional::DefineProtocol(:foo)).to_not be_nil
      end

      it 'returns nil when not defined' do
        expect(Functional::DefineProtocol(:foo)).to be_nil
      end
    end

    context 'with a block' do

      it 'raises an exception if the protocol has already been specified' do
        Functional::DefineProtocol(:Foo){ nil }

        expect {
          Functional::DefineProtocol(:Foo){ nil }
        }.to raise_error(Functional::ProtocolError)
      end

      it 'specifies an instance method with any arity' do
        Functional::DefineProtocol :Foo do
          method :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:methods][:foo]).to be_nil
      end

      it 'specifies an instance method with a given arity' do
        Functional::DefineProtocol :Foo do
          method :foo, 2
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:methods][:foo]).to eq 2
      end

      it 'specifies a class method with any arity' do
        Functional::DefineProtocol :Foo do
          class_method :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:class_methods][:foo]).to be_nil
      end

      it 'specifies a class method with a given arity' do
        Functional::DefineProtocol :Foo do
          class_method :foo, 2
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:class_methods][:foo]).to eq 2
      end

      it 'specifies an instance attribute reader' do
        Functional::DefineProtocol :Foo do
          attr_reader :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:methods][:foo]).to eq 0
      end

      it 'specifies an instance attribute writer' do
        Functional::DefineProtocol :Foo do
          attr_writer :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:methods][:foo=]).to eq 1
      end

      it 'specifies an instance attribute accessor' do
        Functional::DefineProtocol :Foo do
          attr_accessor :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:methods][:foo]).to eq 0
        expect(info[:methods][:foo=]).to eq 1
      end

      it 'specifies a class attribute reader' do
        Functional::DefineProtocol :Foo do
          class_attr_reader :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:class_methods][:foo]).to eq 0
      end

      it 'specifies a class attribute writer' do
        Functional::DefineProtocol :Foo do
          class_attr_writer :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:class_methods][:foo=]).to eq 1
      end

      it 'specifies a class attribute accessor' do
        Functional::DefineProtocol :Foo do
          class_attr_accessor :foo
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:class_methods][:foo]).to eq 0
        expect(info[:class_methods][:foo=]).to eq 1
      end

      it 'specifies a constant' do
        Functional::DefineProtocol :Foo do
          constant :FOO
        end

        info = Functional::DefineProtocol(:Foo)
        expect(info[:constants]).to include :FOO
      end

      it 'returns the specified protocol once defined' do
        expect(Functional::DefineProtocol(:Foo){ nil }).to_not be_nil
      end
    end
  end

  describe Functional::ProtocolCheck do

    let!(:checker) do
      Class.new {
        include Functional::ProtocolCheck
      }.new
    end

    context 'Satisfy?' do

      it 'validates methods with no parameters' do
        Functional::DefineProtocol(:foo) do
          method(:bar, 0)
          class_method(:baz, 0)
        end

        clazz = Class.new do
          def bar(); nil; end
          def self.baz(); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      it 'validates methods with a fixed number of parameters' do
        Functional::DefineProtocol(:foo) do
          method(:bar, 3)
          class_method(:baz, 3)
        end

        clazz = Class.new do
          def bar(a,b,c); nil; end
          def self.baz(a,b,c); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      it 'validates methods with optional parameters' do
        Functional::DefineProtocol(:foo) do
          method(:bar, -2)
          class_method(:baz, -2)
        end

        clazz = Class.new do
          def bar(a, b=1); nil; end
          def self.baz(a, b=1, c=2); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      ##NOTE: Syntax error on JRuby and Rbx
      #it 'validates methods with keyword parameters' do
        #Functional::DefineProtocol(:foo) do
          #method(:bar, -2)
          #class_method(:baz, -3)
        #end

        #clazz = Class.new do
          #def bar(a, foo: 'foo', baz: 'baz'); nil; end
          #def self.baz(a, b, foo: 'foo', baz: 'baz'); nil; end
        #end

        #expect(checker.Satisfy?(clazz.new, :foo)).to be true
      #end

      it 'validates methods with variable length argument lists' do
        Functional::DefineProtocol(:foo) do
          method(:bar, -2)
          class_method(:baz, -3)
        end

        clazz = Class.new do
          def bar(a, *args); nil; end
          def self.baz(a, b, *args); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      it 'validates methods with arity -1' do
        Functional::DefineProtocol(:foo) do
          method(:bar, -1)
          class_method(:baz, -1)
        end

        clazz = Class.new do
          def bar(*args); nil; end
          def self.baz(*args); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      it 'validates instance attribute accessors' do
        Functional::DefineProtocol(:foo) do
          attr_accessor :foo
        end

        accessor_clazz = Class.new do
          attr_accessor :foo
        end

        manual_clazz = Class.new do
          def foo() true; end
          def foo=(value) true; end
        end

        expect(checker.Satisfy?(accessor_clazz.new, :foo)).to be true
        expect(checker.Satisfy?(manual_clazz.new, :foo)).to be true
      end

      it 'validates class attribute accessors' do
        Functional::DefineProtocol(:foo) do
          class_attr_accessor :foo
        end

        accessor_clazz = Class.new do
          class << self
            attr_accessor :foo
          end
        end

        manual_clazz = Class.new do
          def self.foo() true; end
          def self.foo=(value) true; end
        end

        expect(checker.Satisfy?(accessor_clazz.new, :foo)).to be true
        expect(checker.Satisfy?(manual_clazz.new, :foo)).to be true
      end

      it 'validates constants' do
        Functional::DefineProtocol :foo do
          constant :FOO
        end

        clazz = Class.new do
          FOO = 42
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      it 'validates classes' do
        Functional::DefineProtocol(:foo) do
          class_method(:baz, -3)
        end

        clazz = Class.new do
          def self.baz(a, b, *args); nil; end
        end

        expect(checker.Satisfy?(clazz, :foo)).to be true
      end

      it 'validates modules' do
        Functional::DefineProtocol(:foo) do
          class_method(:baz, -3)
        end

        clazz = Module.new do
          def bar(a, *args); nil; end
          def self.baz(a, b, *args); nil; end
        end

        expect(checker.Satisfy?(clazz, :foo)).to be true
      end

      it 'always accepts methods when arity not given' do
        Functional::DefineProtocol(:foo) do
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

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      it 'always accepts methods with arity -1' do
        Functional::DefineProtocol(:foo) do
          method(:foo, 0)
          method(:bar, 2)
          method(:baz, -2)
          class_method(:foo, 0)
          class_method(:bar, -2)
          class_method(:baz, 2)
        end

        clazz = Class.new do
          def foo(*args); nil; end
          def bar(*args); nil; end
          def baz(*args); nil; end
          def self.foo(*args); nil; end
          def self.bar(*args); nil; end
          def self.baz(*args); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be true
      end

      it 'accepts and checks multiple protocols' do
        Functional::DefineProtocol(:foo){ method(:foo) }
        Functional::DefineProtocol(:bar){ method(:foo) }
        Functional::DefineProtocol(:baz){ method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          checker.Satisfy?(clazz.new, :foo, :bar, :baz)
        ).to be true
      end

      it 'returns false if one or more instance methods do not match' do
        Functional::DefineProtocol(:foo) do
          method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be false
      end

      it 'returns false if one or more class methods do not match' do
        Functional::DefineProtocol(:foo) do
          class_method(:bar, 0)
        end

        clazz = Class.new do
          def self.bar(a, b, *args); nil; end
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be false
      end

      it 'returns false if one or more instance attributes does not match' do
        Functional::DefineProtocol(:foo) do
          attr_accessor :foo
        end

        reader_clazz = Class.new do
          def foo() true; end
          def foo=() false; end
        end

        writer_clazz = Class.new do
          def foo(value) false; end
          def foo=(value) true; end
        end

        expect(checker.Satisfy?(reader_clazz.new, :foo)).to be false
        expect(checker.Satisfy?(writer_clazz.new, :foo)).to be false
      end

      it 'returns false if one or more class attributes does not match' do
        Functional::DefineProtocol(:foo) do
          class_attr_accessor :foo
        end

        reader_clazz = Class.new do
          def self.foo() true; end
          def self.foo=() false; end
        end

        writer_clazz = Class.new do
          def self.foo(value) false; end
          def self.foo=(value) true; end
        end

        expect(checker.Satisfy?(reader_clazz.new, :foo)).to be false
        expect(checker.Satisfy?(writer_clazz.new, :foo)).to be false
      end

      it 'returns false if one or more constants has not been defined' do
        Functional::DefineProtocol :foo do
          constant :FOO
        end

        clazz = Class.new do
          BAR = 42
        end

        expect(checker.Satisfy?(clazz.new, :foo)).to be false
      end

      it 'returns false if one or more protocols has not been defined' do
        Functional::DefineProtocol(:foo) do
          method(:bar, 0)
          class_method(:bar, 0)
        end

        expect(
          checker.Satisfy?('object', :foo, :bar)
        ).to be false
      end
    end

    context 'Satisfy!' do

      it 'returns the target on success' do
        Functional::DefineProtocol(:foo) do
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
        expect(checker.Satisfy!(target, :foo)).to eq target
      end

      it 'raises an exception if one or more instance methods do not match' do
        Functional::DefineProtocol(:foo) do
          method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect {
          checker.Satisfy!(clazz.new, :foo)
        }.to raise_error(Functional::ProtocolError)
      end

      it 'raises an exception if one or more class methods do not match' do
        Functional::DefineProtocol(:foo) do
          class_method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect {
          checker.Satisfy!(clazz.new, :foo)
        }.to raise_error(Functional::ProtocolError)
      end

      it 'raises an exception if one or more protocols has not been defined' do
        Functional::DefineProtocol(:foo) do
          method(:bar, 0)
          class_method(:bar, 0)
        end

        expect {
          checker.Satisfy!('object', :foo)
        }.to raise_error(Functional::ProtocolError)
      end
    end

    context 'Protocol?' do

      it 'returns true when all protocols have been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }
        Functional::DefineProtocol(:baz){ nil }

        expect(checker.Protocol?(:foo, :bar, :baz)).to be true
      end

      it 'returns false when one or more of the protocols have not been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }

        expect(checker.Protocol?(:foo, :bar, :baz)).to be false
      end
    end

    context 'Protocol!' do

      it 'returns true when all protocols have been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }
        Functional::DefineProtocol(:baz){ nil }

        expect(checker.Protocol!(:foo, :bar, :baz)).to be true
        expect {
          checker.Protocol!(:foo, :bar, :baz)
        }.to_not raise_error
      end

      it 'raises an exception when one or more of the protocols have not been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }

        expect {
          checker.Protocol!(:foo, :bar, :baz)
        }.to raise_error(Functional::ProtocolError)
      end
    end
  end
end
