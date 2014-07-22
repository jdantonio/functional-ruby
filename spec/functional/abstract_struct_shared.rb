shared_examples :abstract_struct do

  specify { Functional::Protocol::Satisfy! struct_class, :Struct }

  let(:other_struct) do
    Class.new do
      include Functional::AbstractStruct
      self.fields = [:foo, :bar, :baz].freeze
      self.datatype = :other_struct
    end
  end

  context 'field collection' do

    it 'contains all possible fields' do
      expected_fields.each do |field|
        expect(struct_class.fields).to include(field)
      end
    end

    it 'is frozen' do
      expect(struct_class.fields).to be_frozen
    end

    it 'does not overwrite fields for other structs' do
      expect(struct_class.fields).to_not eq other_struct.fields
    end

    it 'is the same when called on the class and on an object' do
      expect(struct_class.fields).to eq struct_object.fields
    end
  end

  context 'readers' do

    specify '#values returns all values in an array' do
      expect(struct_object.values).to eq expected_values
    end

    specify '#values is frozen' do
      expect(struct_object.values).to be_frozen
    end

    specify 'exist for each field' do
      expected_fields.each do |field|
        expect(struct_object).to respond_to(field)
        expect(struct_object.method(field).arity).to eq 0
      end
    end

    specify 'return the appropriate value all fields' do
      expected_fields.each_with_index do |field, i|
        expect(struct_object.send(field)).to eq expected_values[i]
      end
    end
  end

  context 'enumeration' do

    specify '#each_pair with a block iterates over all fields and values' do
      fields = []
      values = []

      struct_object.each_pair do |field, value|
        fields << field
        values << value
      end

      expect(fields).to eq struct_object.fields
      expect(values).to eq struct_object.values
    end

    specify '#each_pair without a block returns an Enumerable' do
      expect(struct_object.each_pair).to be_a Enumerable
    end

    specify '#each with a block iterates over all values' do
      values = []

      struct_object.each do |value|
        values << value
      end

      expect(values).to eq struct_object.values
    end

    specify '#each without a block returns an Enumerable' do
      expect(struct_object.each).to be_a Enumerable
    end
  end

  context 'reflection' do

    specify 'always creates frozen objects' do
      expect(struct_object).to be_frozen
    end

    specify 'asserts equality for two structs of the same class with equal values' do
      other = struct_object.dup

      expect(struct_object).to eq other
      expect(struct_object).to eql other
    end

    specify 'rejects equality for two structs of different classes' do
      other = Struct.new(*expected_fields).new(*expected_values)

      expect(struct_object).to_not eq other
      expect(struct_object).to_not eql other
    end

    specify 'rejects equality for two structs of the same class with different values' do
      pending
      other = struct_object.dup

      expect(struct_object).to_not eq other
      expect(struct_object).to_not eql other
    end

    specify '#to_h returns a Hash with all field/value pairs' do
      hsh = struct_object.to_h

      expect(hsh.keys).to eq struct_object.fields
      expect(hsh.values).to eq struct_object.values
    end

    specify '#inspect result is enclosed in brackets' do
      expect(struct_object.inspect).to match(/^#</)
      expect(struct_object.inspect).to match(/>$/)
    end

    specify '#inspect result has lowercase class name as first element' do
      struct = described_class.to_s.split('::').last.downcase
      expect(struct_object.inspect).to match(/^#<#{struct} /)
    end

    specify '#inspect includes all field/value pairs' do
      struct_object.fields.each_with_index do |field, i|
        value_regex = "\"?#{struct_object.values[i]}\"?"
        expect(struct_object.inspect).to match(/:#{field}=>#{value_regex}/)
      end
    end

    specify '#inspect is aliased as #to_s' do
      expect(struct_object.inspect).to eq struct_object.to_s
    end

    specify '#length returns the number of fields' do
      expect(struct_object.length).to eq struct_class.fields.length
      expect(struct_object.length).to eq expected_fields.length
    end

    specify 'aliases #length as #size' do
      expect(struct_object.length).to eq struct_object.size
    end
  end
end
