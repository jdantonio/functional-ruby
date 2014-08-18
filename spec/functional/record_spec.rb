require 'spec_helper'
require_relative 'abstract_struct_shared'
require 'securerandom'

module Functional

  describe Record do

    let!(:expected_fields){ [:a, :b, :c] }
    let!(:expected_values){ [42, nil, nil] }

    let(:struct_class) { Record.new(*expected_fields) }
    let(:struct_object) { struct_class.new(struct_class.fields.first => 42) }
    let(:other_object) { struct_class.new(struct_class.fields.first => Object.new) }

    it_should_behave_like :abstract_struct

    context 'definition' do

      it 'does not register a new class when no name is given' do
        Record.new(:foo, :bar, :baz)
        expect(defined?(Record::Foo)).to be_falsey
      end

      it 'creates a new class when given an array of field names' do
        clazz = Record.new(:foo, :bar, :baz)
        expect(clazz).to be_a Class
        expect(clazz.ancestors).to include(Functional::AbstractStruct)
      end

      it 'registers the new class with Record when given a string name and an array' do
        Record.new('Bar', :foo, :bar, :baz)
        expect(defined?(Record::Bar)).to eq 'constant'
      end

      it 'creates a new class when given a hash of field names and types/protocols' do
        clazz = Record.new(foo: String, bar: String, baz: String)
        expect(clazz).to be_a Class
        expect(clazz.ancestors).to include(Functional::AbstractStruct)
      end

      it 'registers the new class with Record when given a string name and a hash' do
        Record.new('Boom', foo: String, bar: String, baz: String)
        expect(defined?(Record::Boom)).to eq 'constant'
      end

      it 'raises an exception when given a hash with an invalid type/protocol' do
        expect {
          Record.new(foo: 'String', bar: String, baz: String)
        }.to raise_error(ArgumentError)
      end

      it 'raises an exception when given an invalid definition' do
        expect {
          Record.new(:foo, bar: String, baz: String)
        }.to raise_error(ArgumentError)
      end
    end

    context 'initialization' do

      it 'sets all fields values to nil' do
        fields = [:foo, :bar, :baz]
        clazz = Record.new(*fields)

        record = clazz.new

        fields.each do |field|
          expect(record.send(field)).to be_nil
        end
      end

      it 'sets initial values based on values given at object construction' do
        clazz = Record.new(:foo, :bar, :baz)
        record = clazz.new(foo: 1, bar: 2, baz: 3)

        expect(record.foo).to eq 1
        expect(record.bar).to eq 2
        expect(record.baz).to eq 3
      end

      context 'with default values' do

        it 'defaults fields to values given during class creation' do
          clazz = Record.new(:foo, :bar, :baz) do
            default :foo, 42
            default :bar, 'w00t!'
          end

          record = clazz.new
          expect(record.foo).to eq 42
          expect(record.bar).to eq 'w00t!'
          expect(record.baz).to be_nil
        end

        it 'overrides default values with values provided at object construction' do
          clazz = Record.new(:foo, :bar, :baz) do
            default :foo, 42
            default :bar, 'w00t!'
            default :baz, :bogus
          end

          record = clazz.new(foo: 1, bar: 2)

          expect(record.foo).to eq 1
          expect(record.bar).to eq 2
          expect(record.baz).to eq :bogus
        end

        it 'duplicates default values when assigning to a new object' do
          original = 'Foo'
          clazz = Record.new(:foo, :bar, :baz) do
            default :foo, original
          end

          record = clazz.new
          expect(record.foo).to eq original
          expect(record.foo.object_id).to_not eql original.object_id
        end

        it 'does not conflate defaults across record classes' do
          clazz_foo = Record.new(:foo, :bar, :baz) do
            default :foo, 42
          end

          clazz_matz = Record.new(:foo, :bar, :baz) do
            default :foo, 'Matsumoto'
          end

          expect(clazz_foo.new.foo).to eq 42
          expect(clazz_matz.new.foo).to eq 'Matsumoto'
        end
      end

      context 'with mandatory fields' do

        it 'raises an exception when values for requred field are not provided' do
          clazz = Record.new(:foo, :bar, :baz) do
            mandatory :foo
          end

          expect {
            clazz.new(bar: 1)
          }.to raise_exception(ArgumentError)
        end

        it 'raises an exception when required values are nil' do
          clazz = Record.new(:foo, :bar, :baz) do
            mandatory :foo
          end

          expect {
            clazz.new(foo: nil, bar: 1)
          }.to raise_exception(ArgumentError)
        end

        it 'allows multiple required fields to be specified together' do
          clazz = Record.new(:foo, :bar, :baz) do
            mandatory :foo, :bar, :baz
          end

          expect {
            clazz.new(foo: 1, bar: 2)
          }.to raise_exception(ArgumentError)

          expect {
            clazz.new(bar: 2, baz: 3)
          }.to raise_exception(ArgumentError)

          expect {
            clazz.new(foo: 1, bar: 2, baz: 3)
          }.to_not raise_exception
        end

        it 'does not conflate default values across record classes' do
          clazz_foo = Record.new(:foo, :bar, :baz) do
            mandatory :foo
          end

          clazz_baz = Record.new(:foo, :bar, :baz) do
            mandatory :baz
          end

          expect {
            clazz_foo.new(foo: 42)
          }.to_not raise_error

          expect {
            clazz_baz.new(baz: 42)
          }.to_not raise_error
        end
      end

      context 'with field type specification' do

        let(:type_safe_definition) do
          {foo: String, bar: Fixnum, baz: protocol}
        end

        let(:protocol){ SecureRandom.uuid.to_sym }

        let(:clazz_with_protocol) do
          Class.new do
            def foo() nil end
          end
        end

        let(:record_clazz) do
          Record.new(type_safe_definition)
        end

        before(:each) do
          Functional::SpecifyProtocol(protocol){ instance_method(:foo) }
        end

        it 'raises an exception for a value with an invalid type' do
          expect {
            record_clazz.new(foo: 'foo', bar: 'bar', baz: clazz_with_protocol.new)
          }.to raise_error(ArgumentError)
        end

        it 'raises an exception for a value that does not satisfy a protocol' do
          expect {
            record_clazz.new(foo: 'foo', bar: 42, baz: 'baz')
          }.to raise_error(ArgumentError)
        end

        it 'creates the object when all values match the appropriate types and protocols' do
          record = record_clazz.new(foo: 'foo', bar: 42, baz: clazz_with_protocol.new)
          expect(record).to be_a record_clazz
        end
      end

      it 'allows a field to be required and have a default value' do
        clazz = Record.new(:foo, :bar, :baz) do
          mandatory :foo
          default :foo, 42
        end

        expect {
          clazz.new
        }.to_not raise_exception

        expect(clazz.new.foo).to eq 42
      end

      it 'raises an exception if the default value for a require field is nil' do
        clazz = Record.new(:foo, :bar, :baz) do
          mandatory :foo
          default :foo, nil
        end

        expect {
          clazz.new
        }.to raise_exception(ArgumentError)
      end
    end

    context 'subclassing' do

      specify 'supports all capabilities on subclasses' do
        record_clazz = Functional::Record.new(:first, :middle, :last, :suffix) do
          mandatory :first, :last
        end

        clazz = Class.new(record_clazz) do
          def full_name
            "#{first} #{last}"
          end

          def formal_name
            name = [first, middle, last].select{|s| ! s.to_s.empty?}.join(' ')
            suffix.to_s.empty? ? name : name + ", #{suffix}"
          end
        end

        jerry = clazz.new(first: 'Jerry', last: "D'Antonio")
        ted = clazz.new(first: 'Ted', middle: 'Theodore', last: 'Logan', suffix: 'Esq.')

        expect(jerry.full_name).to eq "Jerry D'Antonio"
        expect(jerry.formal_name).to eq "Jerry D'Antonio"

        expect(ted.full_name).to eq "Ted Logan"
        expect(ted.formal_name).to eq "Ted Theodore Logan, Esq."
      end
    end
  end
end
