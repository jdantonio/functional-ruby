module Functional

  describe ProtocolInfo do

    let!(:kitchen_sink) do
      ProtocolInfo.new(:Everything) do
        instance_method     :instance_method
        class_method        :class_method
        attr_accessor       :attr_accessor
        attr_reader         :attr_reader
        attr_writer         :attr_writer
        class_attr_accessor :class_attr_accessor
        class_attr_reader   :class_attr_reader
        class_attr_writer   :class_attr_writer
        constant            :CONSTANT
      end
    end

    context '#initialize' do

      it 'raises an exception when no block is given' do
        expect {
          ProtocolInfo.new(:Foo)
        }.to raise_error(ArgumentError)
      end

      it 'raises an exception when the name is nil' do
        expect {
          ProtocolInfo.new(nil){ nil }
        }.to raise_error(ArgumentError)
      end

      it 'raises an exception when the name is blank' do
        expect {
          ProtocolInfo.new(''){ nil }
        }.to raise_error(ArgumentError)
      end

      it 'specifies an instance method with no arity given' do
        info = ProtocolInfo.new(:Foo) do
          instance_method :foo
        end

        expect(info.instance_methods[:foo]).to be_nil
      end

      it 'specifies an instance method with a given arity' do
        info = ProtocolInfo.new(:Foo) do
          instance_method :foo, 2
        end

        expect(info.instance_methods[:foo]).to eq 2
      end

      it 'specifies a class method with any arity' do
        info = ProtocolInfo.new(:Foo) do
          class_method :foo
        end

        expect(info.class_methods[:foo]).to be_nil
      end

      it 'specifies a class method with a given arity' do
        info = ProtocolInfo.new(:Foo) do
          class_method :foo, 2
        end

        expect(info.class_methods[:foo]).to eq 2
      end

      it 'specifies an instance attribute reader' do
        info = ProtocolInfo.new(:Foo) do
          attr_reader :foo
        end

        expect(info.instance_methods[:foo]).to eq 0
      end

      it 'specifies an instance attribute writer' do
        info = ProtocolInfo.new(:Foo) do
          attr_writer :foo
        end

        expect(info.instance_methods[:foo=]).to eq 1
      end

      it 'specifies an instance attribute accessor' do
        info = ProtocolInfo.new(:Foo) do
          attr_accessor :foo
        end

        expect(info.instance_methods[:foo]).to eq 0
        expect(info.instance_methods[:foo=]).to eq 1
      end

      it 'specifies a class attribute reader' do
        info = ProtocolInfo.new(:Foo) do
          class_attr_reader :foo
        end

        expect(info.class_methods[:foo]).to eq 0
      end

      it 'specifies a class attribute writer' do
        info = ProtocolInfo.new(:Foo) do
          class_attr_writer :foo
        end

        expect(info.class_methods[:foo=]).to eq 1
      end

      it 'specifies a class attribute accessor' do
        info = ProtocolInfo.new(:Foo) do
          class_attr_accessor :foo
        end

        expect(info.class_methods[:foo]).to eq 0
        expect(info.class_methods[:foo=]).to eq 1
      end

      it 'specifies a constant' do
        info = ProtocolInfo.new(:Foo) do
          constant :FOO
        end

        expect(info.constants).to include :FOO
      end
    end

    context '#satisfies?' do

      it 'validates methods with no arity given' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:bar)
          class_method(:baz)
        end

        clazz = Class.new do
          def bar(a, b, c=1, d=2, *args); nil; end
          def self.baz(); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be true
      end

      it 'validates methods with no parameters' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:bar, 0)
          class_method(:baz, 0)
        end

        clazz = Class.new do
          def bar(); nil; end
          def self.baz(); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be true
      end

      it 'validates methods with a fixed number of parameters' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:bar, 3)
          class_method(:baz, 3)
        end

        clazz = Class.new do
          def bar(a,b,c); nil; end
          def self.baz(a,b,c); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be true
      end

      it 'validates methods with optional parameters' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:bar, -2)
          class_method(:baz, -2)
        end

        clazz = Class.new do
          def bar(a, b=1); nil; end
          def self.baz(a, b=1, c=2); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be true
      end

      ##NOTE: Syntax error on JRuby and Rbx
      #it 'validates methods with keyword parameters' do
      #  info = ProtocolInfo.new(:Foo) do
      #    instance_method(:bar, -2)
      #    class_method(:baz, -3)
      #  end
      #
      #  clazz = Class.new do
      #    def bar(a, foo: 'foo', baz: 'baz'); nil; end
      #    def self.baz(a, b, foo: 'foo', baz: 'baz'); nil; end
      #  end
      #
      #  expect(info.satisfies?(clazz.new)).to be true
      #end

      it 'validates methods with variable length argument lists' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:bar, -2)
          class_method(:baz, -3)
        end

        clazz = Class.new do
          def bar(a, *args); nil; end
          def self.baz(a, b, *args); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be true
      end

      it 'validates methods with arity -1' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:bar, -1)
          class_method(:baz, -1)
        end

        clazz = Class.new do
          def bar(*args); nil; end
          def self.baz(*args); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be true
      end

      it 'validates instance attribute accessors' do
        info = ProtocolInfo.new(:Foo) do
          attr_accessor :foo
        end

        accessor_clazz = Class.new do
          attr_accessor :foo
        end

        manual_clazz = Class.new do
          def foo() true; end
          def foo=(value) true; end
        end

        expect(info.satisfies?(accessor_clazz.new)).to be true
        expect(info.satisfies?(manual_clazz.new)).to be true
      end

      it 'validates class attribute accessors' do
        info = ProtocolInfo.new(:Foo) do
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

        expect(info.satisfies?(accessor_clazz.new)).to be true
        expect(info.satisfies?(manual_clazz.new)).to be true
      end

      it 'validates constants' do
        info = ProtocolInfo.new(:Foo) do
          constant :FOO
        end

        clazz = Class.new do
          FOO = 42
        end

        expect(info.satisfies?(clazz.new)).to be false
      end

      it 'always accepts methods when arity not given' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:foo)
          instance_method(:bar)
          instance_method(:baz)
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

        expect(info.satisfies?(clazz.new)).to be true
      end

      it 'always accepts methods with arity -1' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:foo, 0)
          instance_method(:bar, 2)
          instance_method(:baz, -2)
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

        expect(info.satisfies?(clazz.new)).to be true
      end

      it 'returns false if one or more instance methods do not match' do
        info = ProtocolInfo.new(:Foo) do
          instance_method(:bar, 0)
        end

        clazz = Class.new do
          def bar(a, b, *args); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be false
      end

      it 'returns false if one or more class methods do not match' do
        info = ProtocolInfo.new(:Foo) do
          class_method(:bar, 0)
        end

        clazz = Class.new do
          def self.bar(a, b, *args); nil; end
        end

        expect(info.satisfies?(clazz.new)).to be false
      end

      it 'returns false if one or more instance attributes does not match' do
        info = ProtocolInfo.new(:Foo) do
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

        expect(info.satisfies?(reader_clazz.new)).to be false
        expect(info.satisfies?(writer_clazz.new)).to be false
      end

      it 'returns false if one or more class attributes does not match' do
        info = ProtocolInfo.new(:Foo) do
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

        expect(info.satisfies?(reader_clazz.new)).to be false
        expect(info.satisfies?(writer_clazz.new)).to be false
      end

      it 'returns false if one or more constants has not been defined' do
        info = ProtocolInfo.new(:Foo) do
          constant :FOO
        end

        clazz = Class.new do
          BAR = 42
        end

        expect(info.satisfies?(clazz.new)).to be false
      end

      it 'supports all specifiable characteristics on classes' do
        clazz = Class.new do
          attr_accessor :attr_accessor
          attr_reader   :attr_reader
          attr_writer   :attr_writer
          def instance_method() 42; end

          class << self
            attr_accessor :class_attr_accessor
            attr_reader   :class_attr_reader
            attr_writer   :class_attr_writer
            def class_method() 42; end
          end
        end
        clazz.const_set(:CONSTANT, 42)

        expect(
          kitchen_sink.satisfies?(clazz)
        ).to be true
      end

      it 'supports all specifiable characteristics on modules' do
        mod = Module.new do
          attr_accessor :attr_accessor
          attr_reader   :attr_reader
          attr_writer   :attr_writer
          def instance_method() 42; end

          class << self
            attr_accessor :class_attr_accessor
            attr_reader   :class_attr_reader
            attr_writer   :class_attr_writer
            def class_method() 42; end
          end
        end
        mod.const_set(:CONSTANT, 42)

        expect(
          kitchen_sink.satisfies?(mod)
        ).to be true
      end
    end
  end
end
