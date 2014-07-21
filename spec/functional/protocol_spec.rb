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
        Functional::DefineProtocol(:Foo){ nil }
        expect(Functional::DefineProtocol(:Foo)).to_not be_nil
      end

      it 'returns nil when not defined' do
        expect(Functional::DefineProtocol(:Foo)).to be_nil
      end
    end

    context 'with a block' do

      it 'raises an exception if the protocol has already been specified' do
        Functional::DefineProtocol(:Foo){ nil }

        expect {
          Functional::DefineProtocol(:Foo){ nil }
        }.to raise_error(Functional::ProtocolError)
      end

      it 'returns the specified protocol once defined' do
        expect(Functional::DefineProtocol(:Foo){ nil }).to be_a Functional::ProtocolInfo
      end
    end
  end

  describe Functional::ProtocolCheck do

    context 'Satisfy?' do

      it 'accepts and checks multiple protocols' do
        Functional::DefineProtocol(:foo){ instance_method(:foo) }
        Functional::DefineProtocol(:bar){ instance_method(:foo) }
        Functional::DefineProtocol(:baz){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          Functional::ProtocolCheck.Satisfy?(clazz.new, :foo, :bar, :baz)
        ).to be true
      end

      it 'returns false if one or more protocols have not been defined' do
        Functional::DefineProtocol(:foo){ instance_method(:foo) }

        expect(
          Functional::ProtocolCheck.Satisfy?('object', :foo, :bar)
        ).to be false
      end

      it 'returns true on success' do
        Functional::DefineProtocol(:foo){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          Functional::ProtocolCheck.Satisfy?(clazz.new, :foo)
        ).to be true
      end

      it 'returns false on failure' do
        Functional::DefineProtocol(:foo) do
          instance_method(:foo, 0)
          class_method(:bar, 0)
        end

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          Functional::ProtocolCheck.Satisfy?('object', :foo)
        ).to be false
      end
    end

    context 'Satisfy!' do

      it 'accepts and checks multiple protocols' do
        Functional::DefineProtocol(:foo){ instance_method(:foo) }
        Functional::DefineProtocol(:bar){ instance_method(:foo) }
        Functional::DefineProtocol(:baz){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        target = clazz.new
        expect(
          Functional::ProtocolCheck.Satisfy!(target, :foo, :bar, :baz)
        ).to eq target
      end

      it 'raises an exception if one or more protocols have not been defined' do
        Functional::DefineProtocol(:foo){ instance_method(:foo) }

        expect{
          Functional::ProtocolCheck.Satisfy!('object', :foo, :bar)
        }.to raise_error(Functional::ProtocolError)
      end

      it 'returns the target on success' do
        Functional::DefineProtocol(:foo){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        target = clazz.new
        expect(
          Functional::ProtocolCheck.Satisfy!(target, :foo)
        ).to eq target
      end

      it 'raises an exception on failure' do
        Functional::DefineProtocol(:foo){ instance_method(:foo) }

        expect{
          Functional::ProtocolCheck.Satisfy!('object', :foo)
        }.to raise_error(Functional::ProtocolError)
      end
    end

    context 'Protocol?' do

      it 'returns true when all protocols have been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }
        Functional::DefineProtocol(:baz){ nil }

        expect(Functional::ProtocolCheck.Protocol?(:foo, :bar, :baz)).to be true
      end

      it 'returns false when one or more of the protocols have not been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }

        expect(Functional::ProtocolCheck.Protocol?(:foo, :bar, :baz)).to be false
      end
    end

    context 'Protocol!' do

      it 'returns true when all protocols have been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }
        Functional::DefineProtocol(:baz){ nil }

        expect(Functional::ProtocolCheck.Protocol!(:foo, :bar, :baz)).to be true
        expect {
          Functional::ProtocolCheck.Protocol!(:foo, :bar, :baz)
        }.to_not raise_error
      end

      it 'raises an exception when one or more of the protocols have not been defined' do
        Functional::DefineProtocol(:foo){ nil }
        Functional::DefineProtocol(:bar){ nil }

        expect {
          Functional::ProtocolCheck.Protocol!(:foo, :bar, :baz)
        }.to raise_error(Functional::ProtocolError)
      end
    end
  end
end
