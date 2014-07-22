require 'spec_helper'
require_relative 'abstract_struct_shared'

module Functional

  describe Option do

    let!(:value){ 42 }

    let!(:expected_fields){ [:some] }
    let!(:expected_values){ [value] }

    let(:struct_class) { Option }
    let(:struct_object) { Option.some(value) }

    let(:some_subject){ Option.some(value) }
    let(:none_subject){ Option.none }

    it_should_behave_like :abstract_struct

    specify{ Functional::Protocol::Satisfy! Option, :Option }

    context 'initialization' do

      it 'cannot be constructed directly' do
        expect {
          Option.new
        }.to raise_error(NameError)
      end

      it 'sets the value when constructed by #some' do
        expect(Option.some(value).some).to eq value
      end

      it 'sets the value to nil when constructed by #none' do
        expect(Option.none.some).to be_nil
      end

      it 'freezes the new object' do
        expect(Option.some(:foo)).to be_frozen
        expect(Option.none).to be_frozen
      end
    end

    context 'state' do

      specify '#some? returns true when the some value is set' do
        expect(some_subject).to be_some
      end

      specify '#some? returns false when none' do
        expect(none_subject).to_not be_some
      end

      specify '#none? returns true when none' do
        expect(none_subject).to be_none
      end

      specify '#none? returns false when the some value is set' do
        expect(some_subject).to_not be_none
      end

      specify '#some returns the some value when some is set' do
        expect(some_subject.some).to eq value
      end

      specify '#some returns nil when none is set' do
        expect(none_subject.some).to be_nil
      end
    end

    context 'length' do

      it 'returns 1 when some'

      it 'returns 0 when none'

      it 'as aliased as #size'
    end

    context '#and' do

      it 'returns false when none'

      it 'returns true when some and other is a some Option'

      it 'returns false when some and other is a none Option'

      it 'passes the value to the given block when some'

      it 'returns true when some and the block returns a truthy value'

      it 'returns false when some and the block returns a falsey value'

      it 'returns true when some and given a truthy value'

      it 'returns false when some and given a falsey value'

      it 'raises an exception when given both a value and a block'
    end

    context '#or' do

      it 'returns true when some'

      it 'returns true when none and other is a some Option'

      it 'returns false when none and other is a none Option'

      it 'returns true when none and the block returns a truthy value'

      it 'returns false when none and the block returns a falsey value'

      it 'returns true when none and given a truthy value'

      it 'returns false when none and given a falsey value'

      it 'raises an exception when given both a value and a block'
    end

    context 'else' do

      it 'returns the value when some'

      it 'returns the given value when none'

      it 'returns the other value when none and given a some Option'

      it 'returns nil when none and given a none Option'

      it 'returns the result of the given block when none'

      it 'raises an exception when given both a value and a block'
    end
  end
end
