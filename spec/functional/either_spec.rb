require 'spec_helper'

module Functional

  describe Either do

    let!(:value){ :foo }
    let!(:reason){ StandardError.new }

    let(:left_subject){ Either.left(reason) }
    let(:right_subject){ Either.right(value) }

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

      it 'aliases #left to #reason' do
        expect(Either.reason(value).left).to eq value
      end

      it 'aliases #right to #value' do
        expect(Either.value(value).right).to eq value
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
  end
end
