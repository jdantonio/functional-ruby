require 'spec_helper'

module Functional

  describe TypeCheck do

    context 'Type?' do

      it 'returns true when value is of any of the types' do
        target = 'foo'
        expect(TypeCheck.Type?(target, String, Array, Hash)).to be true
      end

      it 'returns false when value is not of any of the types' do
        target = 'foo'
        expect(TypeCheck.Type?(target, Fixnum, Array, Hash)).to be false
      end
    end

    context 'Type!' do

      it 'returns the value when value is of any of the types' do
        target = 'foo'
        expect(TypeCheck.Type!(target, String, Array, Hash)).to be target
      end

      it 'raises an exception when value is not of any of the types' do
        target = 'foo'
        expect {
          TypeCheck.Type!(target, Fixnum, Array, Hash)
        }.to raise_error(TypeError)
      end
    end

    context 'Match?' do

      it 'returns true when value is an exact match for at least one of the types' do
        target = 'foo'
        expect(TypeCheck.Match?(target, String, Array, Hash)).to be true
      end

      it 'returns false when value is not an exact match for at least one of the types' do
        target = 'foo'
        expect(TypeCheck.Match?(target, Fixnum, Array, Hash)).to be false
      end
    end

    context 'Match!' do

      it 'returns the value when value is an exact match for at least one of the types' do
        target = 'foo'
        expect(TypeCheck.Match!(target, String, Array, Hash)).to eq target
      end

      it 'raises an exception when value is not an exact match for at least one of the types' do
        target = 'foo'
        expect {
          expect(TypeCheck.Match!(target, Fixnum, Array, Hash)).to eq target
        }.to raise_error(TypeError)
      end
    end

    context 'Child?' do

      it 'returns true if value is a class and is also a match or subclass of one of types' do
        target = String
        expect(TypeCheck.Child?(target, Comparable, Array, Hash)).to be true
      end

      it 'returns false if value is not a class' do
        target = 'foo'
        expect(TypeCheck.Child?(target, Comparable, Array, Hash)).to be false
      end

      it 'returns false if value is not a subclass/match for any of the types' do
        target = Fixnum
        expect(TypeCheck.Child?(target, Symbol, Array, Hash)).to be false
      end
    end

    context 'Child!' do

      it 'returns the value if value is a class and is also a match or subclass of one of types' do
        target = String
        expect(TypeCheck.Child!(target, Comparable, Array, Hash)).to eq target
      end

      it 'raises an exception if value is not a class' do
        target = 'foo'
        expect {
          TypeCheck.Child!(target, Comparable, Array, Hash)
        }.to raise_error(TypeError)
      end

      it 'raises an exception if value is not a subclass/match for any of the types' do
        target = Fixnum
        expect {
          TypeCheck.Child!(target, Symbol, Array, Hash)
        }.to raise_error(TypeError)
      end
    end
  end
end
