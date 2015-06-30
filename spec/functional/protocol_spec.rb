describe 'protocol specification' do

  before(:each) do
    @protocol_info = Functional::Protocol.class_variable_get(:@@info)
    Functional::Protocol.class_variable_set(:@@info, {})
  end

  after(:each) do
    Functional::Protocol.class_variable_set(:@@info, @protocol_info)
  end

  context 'SpecifyProtocol method' do

    context 'without a block' do

      it 'returns the specified protocol when defined' do
        Functional::SpecifyProtocol(:Foo){ nil }
        expect(Functional::SpecifyProtocol(:Foo)).to_not be_nil
      end

      it 'returns nil when not defined' do
        expect(Functional::SpecifyProtocol(:Foo)).to be_nil
      end
    end

    context 'with a block' do

      it 'raises an exception if the protocol has already been specified' do
        Functional::SpecifyProtocol(:Foo){ nil }

        expect {
          Functional::SpecifyProtocol(:Foo){ nil }
        }.to raise_error(Functional::ProtocolError)
      end

      it 'returns the specified protocol once defined' do
        expect(Functional::SpecifyProtocol(:Foo){ nil }).to be_a Functional::ProtocolInfo
      end
    end
  end

  describe Functional::Protocol do

    context 'Satisfy?' do

      it 'accepts and checks multiple protocols' do
        Functional::SpecifyProtocol(:foo){ instance_method(:foo) }
        Functional::SpecifyProtocol(:bar){ instance_method(:foo) }
        Functional::SpecifyProtocol(:baz){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          Functional::Protocol.Satisfy?(clazz.new, :foo, :bar, :baz)
        ).to be true
      end

      it 'returns false if one or more protocols have not been defined' do
        Functional::SpecifyProtocol(:foo){ instance_method(:foo) }

        expect(
          Functional::Protocol.Satisfy?('object', :foo, :bar)
        ).to be false
      end

      it 'raises an exception if no protocols are listed' do
        expect {
          Functional::Protocol::Satisfy?('object')
        }.to raise_error(ArgumentError)
      end

      it 'returns true on success' do
        Functional::SpecifyProtocol(:foo){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          Functional::Protocol.Satisfy?(clazz.new, :foo)
        ).to be true
      end

      it 'returns false on failure' do
        Functional::SpecifyProtocol(:foo) do
          instance_method(:foo, 0)
          class_method(:bar, 0)
        end

        clazz = Class.new do
          def foo(); nil; end
        end

        expect(
          Functional::Protocol.Satisfy?(clazz.new, :foo)
        ).to be false
      end

      it 'validates classes' do
        Functional::SpecifyProtocol(:foo) do
          instance_method(:foo)
          class_method(:bar)
        end

        clazz = Class.new do
          def foo(); nil; end
          def self.bar(); nil; end
        end

        expect(
          Functional::Protocol.Satisfy?(clazz, :foo)
        ).to be true
      end

      it 'validates modules' do
        Functional::SpecifyProtocol(:foo) do
          instance_method(:foo)
          class_method(:bar)
        end

        mod = Module.new do
          def foo(); nil; end
          def self.bar(); nil; end
        end

        expect(
          Functional::Protocol.Satisfy?(mod, :foo)
        ).to be true
      end
    end

    context 'Satisfy!' do

      it 'accepts and checks multiple protocols' do
        Functional::SpecifyProtocol(:foo){ instance_method(:foo) }
        Functional::SpecifyProtocol(:bar){ instance_method(:foo) }
        Functional::SpecifyProtocol(:baz){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        target = clazz.new
        expect(
          Functional::Protocol.Satisfy!(target, :foo, :bar, :baz)
        ).to eq target
      end

      it 'raises an exception if one or more protocols have not been defined' do
        Functional::SpecifyProtocol(:foo){ instance_method(:foo) }

        expect{
          Functional::Protocol.Satisfy!('object', :foo, :bar)
        }.to raise_error(Functional::ProtocolError)
      end

      it 'raises an exception if no protocols are listed' do
        expect {
          Functional::Protocol::Satisfy!('object')
        }.to raise_error(ArgumentError)
      end

      it 'returns the target on success' do
        Functional::SpecifyProtocol(:foo){ instance_method(:foo) }

        clazz = Class.new do
          def foo(); nil; end
        end

        target = clazz.new
        expect(
          Functional::Protocol.Satisfy!(target, :foo)
        ).to eq target
      end

      it 'raises an exception on failure' do
        Functional::SpecifyProtocol(:foo){ instance_method(:foo) }

        expect{
          Functional::Protocol.Satisfy!('object', :foo)
        }.to raise_error(Functional::ProtocolError)
      end

      it 'validates classes' do
        Functional::SpecifyProtocol(:foo) do
          instance_method(:foo)
          class_method(:bar)
        end

        clazz = Class.new do
          def foo(); nil; end
          def self.bar(); nil; end
        end

        expect{
          Functional::Protocol.Satisfy!(clazz, :foo)
        }.to_not raise_exception
      end

      it 'validates modules' do
        Functional::SpecifyProtocol(:foo) do
          instance_method(:foo)
          class_method(:bar)
        end

        mod = Module.new do
          def foo(); nil; end
          def self.bar(); nil; end
        end

        expect{
          Functional::Protocol.Satisfy!(mod, :foo)
        }.to_not raise_exception
      end
    end

    context 'Specified?' do

      it 'returns true when all protocols have been defined' do
        Functional::SpecifyProtocol(:foo){ nil }
        Functional::SpecifyProtocol(:bar){ nil }
        Functional::SpecifyProtocol(:baz){ nil }

        expect(Functional::Protocol.Specified?(:foo, :bar, :baz)).to be true
      end

      it 'returns false when one or more of the protocols have not been defined' do
        Functional::SpecifyProtocol(:foo){ nil }
        Functional::SpecifyProtocol(:bar){ nil }

        expect(Functional::Protocol.Specified?(:foo, :bar, :baz)).to be false
      end

      it 'raises an exception when no protocols are given' do
        expect {
          Functional::Protocol.Specified?
        }.to raise_error(ArgumentError)
      end
    end

    context 'Specified!' do

      it 'returns true when all protocols have been defined' do
        Functional::SpecifyProtocol(:foo){ nil }
        Functional::SpecifyProtocol(:bar){ nil }
        Functional::SpecifyProtocol(:baz){ nil }

        expect(Functional::Protocol.Specified!(:foo, :bar, :baz)).to be true
        expect {
          Functional::Protocol.Specified!(:foo, :bar, :baz)
        }.to_not raise_error
      end

      it 'raises an exception when one or more of the protocols have not been defined' do
        Functional::SpecifyProtocol(:foo){ nil }
        Functional::SpecifyProtocol(:bar){ nil }

        expect {
          Functional::Protocol.Specified!(:foo, :bar, :baz)
        }.to raise_error(Functional::ProtocolError)
      end

      it 'raises an exception when no protocols are given' do
        expect {
          Functional::Protocol.Specified!
        }.to raise_error(ArgumentError)
      end
    end
  end
end
