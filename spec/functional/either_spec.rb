require 'spec_helper'
require_relative 'abstract_struct_shared'

module Functional

  describe Either do

    let!(:value){ 42 }
    let!(:reason){ StandardError.new }

    let!(:expected_fields){ [:left, :right] }
    let!(:expected_values){ [value, nil] }

    let(:struct_class) { Either }
    let(:struct_object) { Either.left(value) }
    let(:other_object) { Either.left(Object.new) }

    let(:left_subject){ Either.left(reason) }
    let(:right_subject){ Either.right(value) }

    it_should_behave_like :abstract_struct

    specify{ Functional::Protocol::Satisfy! Either, :Either }
    specify{ Functional::Protocol::Satisfy! Either, :Disposition }

    context 'initialization' do

      it 'cannot be constructed directly' do
        expect {
          Either.new
        }.to raise_error(NameError)
      end

      it 'sets the left value when constructed by #left' do
        expect(Either.left(value).left).to eq value
      end

      it 'sets the right value when constructed by #right' do
        expect(Either.right(value).right).to eq value
      end

      it 'freezes the new object' do
        expect(Either.left(:foo)).to be_frozen
        expect(Either.right(:foo)).to be_frozen
      end

      it 'aliases #left to #reason' do
        expect(Either.reason(value).left).to eq value
      end

      it 'aliases #right to #value' do
        expect(Either.value(value).right).to eq value
      end

      context '#error' do

        it 'sets left to a StandardError with backtrace when no arguments given' do
          either = Either.error
          expect(either.left).to be_a StandardError
          expect(either.left.message).to_not be nil
          expect(either.left.backtrace).to_not be_empty
        end

        it 'sets left to a StandardError with the given message' do
          message = 'custom error message'
          either = Either.error(message)
          expect(either.left).to be_a StandardError
          expect(either.left.message).to eq message
          expect(either.left.backtrace).to_not be_empty
        end

        it 'sets left to an object of the given class with the given message' do
          message = 'custom error message'
          error_class = ArgumentError
          either = Either.error(message, error_class)
          expect(either.left).to be_a error_class
          expect(either.left.message).to eq message
          expect(either.left.backtrace).to_not be_empty
        end
      end
    end

    context 'state' do

      specify '#left? returns true when the left value is set' do
        expect(left_subject).to be_left
      end

      specify '#left? returns false when the right value is set' do
        expect(right_subject).to_not be_left
      end

      specify '#right? returns true when the right value is set' do
        expect(right_subject).to be_right
      end

      specify '#right? returns false when the left value is set' do
        expect(left_subject).to_not be_right
      end

      specify '#left returns the left value when left is set' do
        expect(left_subject.left).to eq reason
      end

      specify '#left returns nil when right is set' do
        expect(right_subject.left).to be_nil
      end

      specify '#right returns the right value when right is set' do
        expect(right_subject.right).to eq value
      end

      specify '#right returns nil when left is set' do
        expect(left_subject.right).to be_nil
      end

      specify 'aliases #left? as #reason?' do
        expect(left_subject.reason?).to be true
      end

      specify 'aliases #right? as #value?' do
        expect(right_subject.value?).to be true
      end

      specify 'aliases #left as #reason' do
        expect(left_subject.reason).to eq reason
        expect(right_subject.reason).to be_nil
      end

      specify 'aliases #right as #value' do
        expect(right_subject.value).to eq value
        expect(left_subject.value).to be_nil
      end
    end

    context '#swap' do

      it 'converts a left projection into a right projection' do
        subject = Either.left(:foo)
        swapped = subject.swap
        expect(swapped).to be_right
        expect(swapped.left).to be_nil
        expect(swapped.right).to eq :foo
      end

      it 'converts a right projection into a left projection' do
        subject = Either.right(:foo)
        swapped = subject.swap
        expect(swapped).to be_left
        expect(swapped.right).to be_nil
        expect(swapped.left).to eq :foo
      end
    end

    context '#either' do

      it 'passes the left value to the left proc when left' do
        expected = nil
        subject = Either.left(100)
        subject.either(
          ->(left) { expected = left },
          ->(right) { expected = -1 }
        )
        expect(expected).to eq 100
      end

      it 'returns the value of the left proc when left' do
        subject = Either.left(100)
        expect(
          subject.either(
            ->(left) { left * 2 },
            ->(right) { nil }
          )
        ).to eq 200
      end

      it 'passes the right value to the right proc when right' do
        expected = nil
        subject = Either.right(100)
        subject.either(
          ->(right) { expected = -1 },
          ->(right) { expected = right }
        )
        expect(expected).to eq 100
      end

      it 'returns the value of the right proc when right' do
        subject = Either.right(100)
        expect(
          subject.either(
            ->(right) { nil },
            ->(right) { right * 2 }
          )
        ).to eq 200
      end
    end

    context '#iif' do

      it 'returns a lefty with the given left value when the boolean is true' do
        subject = Either.iff(:foo, :bar, true)
        expect(subject).to be_left
        expect(subject.left).to eq :foo
      end

      it 'returns a righty with the given right value when the boolean is false' do
        subject = Either.iff(:foo, :bar, false)
        expect(subject).to be_right
        expect(subject.right).to eq :bar
      end

      it 'returns a lefty with the given left value when the block is truthy' do
        subject = Either.iff(:foo, :bar){ :baz }
        expect(subject).to be_left
        expect(subject.left).to eq :foo
      end

      it 'returns a righty with the given right value when the block is false' do
        subject = Either.iff(:foo, :bar){ false }
        expect(subject).to be_right
        expect(subject.right).to eq :bar
      end

      it 'returns a righty with the given right value when the block is nil' do
        subject = Either.iff(:foo, :bar){ nil }
        expect(subject).to be_right
        expect(subject.right).to eq :bar
      end

      it 'raises an exception when both a boolean and a block are given' do
        expect {
          subject = Either.iff(:foo, :bar, true){ nil }
        }.to raise_error(ArgumentError)
      end
    end
  end
end
