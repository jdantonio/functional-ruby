require 'spec_helper'

module Functional

  describe FinalVar do

    context 'instanciation' do

      it 'is unset when no arguments given'

      it 'is set with the given argument'
    end

    context '#get' do

      it 'returns nil when unset'

      it 'returns the value when set'

      it 'is aliased as #value'
    end

    context '#set' do

      it 'sets the value when unset'

      it 'raises an exception when already set'

      it 'is aliased as #value='
    end

    context '#set?' do

      it 'returns false when unset'

      it 'returns true when set'

      it 'is aliased as value?'
    end

    context '#get_or_set' do

      it 'sets the value when unset'

      it 'returns the new value when previously unset'

      it 'returns the current value when already set'
    end

    context '#fetch' do

      it 'returns the given default value when unset'

      it 'does not change the current value when unset'

      it 'returns the current value when already set'
    end

    context 'reflection' do

      specify '#eql? returns false when unset'

      specify '#eql? returns false when set and the value does not match other'

      specify '#eql? returns true when set and the value matches other'

      specify '#inspect includes the word "value" and the value when set'

      specify '#inspect include the word "unset" when unset'

      specify '#to_s returns nil as a string when unset'

      specify '#to_s returns the value as a string when set'
    end

    context 'metaprogramming' do

      it 'when set defines #get and #value on the singleton class'

      it 'when set defines #set? and #value? on the singleton class'

      it 'when set defines #set and #value= on the singleton class'
    end
  end
end
