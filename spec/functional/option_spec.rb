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
    specify{ Functional::Protocol::Satisfy! Option, :Disposition }

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

      it 'aliases #some? as #fulfilled?' do
        expect(some_subject).to be_fulfilled
        expect(none_subject).to_not be_fulfilled
      end

      it 'aliases #some? as #value?' do
        expect(some_subject).to be_value
        expect(none_subject).to_not be_value
      end

      it 'aliases #none? as #rejected?' do
        expect(some_subject).to_not be_rejected
        expect(none_subject).to be_rejected
      end

      it 'aliases #none? as #reason?' do
        expect(some_subject).to_not be_reason
        expect(none_subject).to be_reason
      end

      it 'aliases #some as #value' do
        expect(some_subject.value).to eq value
        expect(none_subject.value).to be_nil
      end

      specify '#reason returns nil when some' do
        expect(some_subject.reason).to be_nil
      end

      specify '#reason returns a truthy value when none' do
        expect(none_subject.reason).to be_truthy
      end
    end

    context 'length' do

      it 'returns 1 when some' do
        expect(Option.some(:foo).length).to eq 1
      end

      it 'returns 0 when none' do
        expect(Option.none.length).to eq 0
      end

      it 'as aliased as #size' do
        expect(Option.some(:foo).size).to eq 1
        expect(Option.none.size).to eq 0
      end
    end

    context '#and' do

      it 'returns false when none' do
        expect(Option.none.and(true)).to be false
      end

      it 'returns true when some and other is a some Option' do
        other = Option.some(42)
        expect(Option.some(:foo).and(other)).to be true
      end

      it 'returns false when some and other is a none Option' do
        other = Option.none
        expect(Option.some(:foo).and(other)).to be false
      end

      it 'passes the value to the given block when some' do
        expected = false
        other = ->(some){ expected = some }
        Option.some(42).and(&other)
        expect(expected).to eq 42
      end

      it 'returns true when some and the block returns a truthy value' do
        other = ->(some){ 'truthy' }
        expect(Option.some(42).and(&other)).to be true
      end

      it 'returns false when some and the block returns a falsey value' do
        other = ->(some){ nil }
        expect(Option.some(42).and(&other)).to be false
      end

      it 'returns true when some and given a truthy value' do
        expect(Option.some(42).and('truthy')).to be true
      end

      it 'returns false when some and given a falsey value' do
        expect(Option.some(42).and(nil)).to be false
      end

      it 'raises an exception when given both a value and a block' do
        expect {
          Option.some(42).and(:foo){|some| :bar  }
        }.to raise_error(ArgumentError)
      end
    end

    context '#or' do

      it 'returns true when some' do
        expect(Option.some(42).or(nil)).to be true
      end

      it 'returns true when none and other is a some Option' do
        other = Option.some(42)
        expect(Option.none.or(other)).to be true
      end

      it 'returns false when none and other is a none Option' do
        other = Option.none
        expect(Option.none.or(other)).to be false
      end

      it 'returns true when none and the block returns a truthy value' do
        other = ->{ 42 }
        expect(Option.none.or(&other)).to be true
      end

      it 'returns false when none and the block returns a falsey value' do
        other = ->{ false }
        expect(Option.none.or(&other)).to be false
      end

      it 'returns true when none and given a truthy value' do
        expect(Option.none.or('truthy')).to be true
      end

      it 'returns false when none and given a falsey value' do
        expect(Option.none.or(nil)).to be false
      end

      it 'raises an exception when given both a value and a block' do
        expect {
          Option.none.and(:foo){ :bar  }
        }.to raise_error(ArgumentError)
      end
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
