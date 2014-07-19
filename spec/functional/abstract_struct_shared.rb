shared_examples :abstract_struct do

  context 'member collection' do

    it 'contains all possible members' do
      expected_members.each do |member|
        expect(struct_class.members).to include(member)
      end
    end

    it 'is frozen' do
      expect(struct_class.members).to be_frozen
    end

    it 'does not overwrite members for other structs' do
      expect(struct_class.members).to_not eq Functional::AbstractStruct.members
    end

    it 'is the same when called on the class and on an object' do
      expect(struct_class.members).to eq struct_object.members
    end
  end

  context 'readers' do

    specify '#values returns all values in an array' do
      expect(struct_object.values).to eq expected_values
    end

    specify '#values is frozen' do
      expect(struct_object.values).to be_frozen
    end

    specify 'exist for each member' do
      expected_members.each do |member|
        expect(struct_object).to respond_to(member)
        expect(struct_object.method(member).arity).to eq 0
      end
    end

    specify 'return the appropriate value all members' do
      expected_members.each_with_index do |member, i|
        expect(struct_object.send(member)).to eq expected_values[i]
      end
    end
  end

  context 'enumeration' do

    specify '#each_pair with a block iterates over all members and values' do
      members = []
      values = []

      struct_object.each_pair do |member, value|
        members << member
        values << value
      end

      expect(members).to eq struct_object.members
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

    specify 'asserts equality for two structs of the same class with equal values' do
      other = struct_object.dup

      expect(struct_object).to eq other
      expect(struct_object).to eql other
    end

    specify 'rejects equality for two structs of different classes' do
      other = Struct.new(*expected_members).new(*expected_values)

      expect(struct_object).to_not eq other
      expect(struct_object).to_not eql other
    end

    specify 'rejects equality for two structs of the same class with different values' do
      pending
      other = struct_object.dup

      expect(struct_object).to_not eq other
      expect(struct_object).to_not eql other
    end

    specify '#to_h returns a Hash with all member/value pairs' do
      hsh = struct_object.to_h

      expect(hsh.keys).to eq struct_object.members
      expect(hsh.values).to eq struct_object.values
    end

    specify '#inspect result is enclosed in brackets' do
      expect(struct_object.inspect).to match(/^#</)
      expect(struct_object.inspect).to match(/>$/)
    end

    specify '#inspect result has lowercase class name as first element' do
      struct = described_class.to_s.gsub('Functional::', '').downcase
      expect(struct_object.inspect).to match(/^#<#{struct} /)
    end

    specify '#inspect includes all member/value pairs' do
      struct_object.members.each_with_index do |member, i|
        value_regex = "\"?#{struct_object.values[i]}\"?"
        expect(struct_object.inspect).to match(/:#{member}=>#{value_regex}/)
      end
    end

    specify '#inspect is aliased as #to_s' do
      expect(struct_object.inspect).to eq struct_object.to_s
    end

    specify '#length returns the number of members' do
      expect(struct_object.length).to eq struct_class.members.length
      expect(struct_object.length).to eq expected_members.length
    end

    specify 'aliases #length as #size' do
      expect(struct_object.length).to eq struct_object.size
    end
  end
end
