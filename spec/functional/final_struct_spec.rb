require 'spec_helper'

module Functional

  describe FinalStruct do

    context 'instanciation' do

      specify 'with no args defines no fields'

      specify 'with a hash defines fields for hash keys'

      specify 'with a hash sets fields using has values'

      specify 'raises an exception if given a non-hash argument'
    end

    context 'set fields' do

      specify 'have a reader which returns the value'

      specify 'have a predicate which returns true'

      specify 'raise an exception when written to again'
    end

    context 'unset fields' do

      specify 'have a magic reader that always returns nil'

      specify 'have a magic predicate that always returns false'

      specify 'have a magic writer that sets the field'
    end

    context 'accessors' do

      specify '#get returns the value of a set field'

      specify '#get returns nil for an unset field'

      specify '#[] is an alias for #get'

      specify '#set sets the value of an unset field'

      specify '#set raises an exception if the field has already been set'

      specify '#[]= is an alias for set'

      specify '#get_or_set returns the value of a set field'

      specify '#get_or_set sets the value of an unset field'

      specify '#get_or_set returns the value of a newly set field'

      specify '#fetch gets the value of an unset field'

      specify '#fetch returns the given value when the field is unset'

      specify '#to_h returns the key/value pairs for all set values'

      specify '#each_pair returns an enumerator when no block given'

      specify '#each_pair enumerates over each field/value pair'
    end

    context 'reflection' do

      specify '#eql? returns true when both define the same fields with the same values'

      specify '#eql? returns false when other has different fields defined'

      specify '#eql? returns false when other has different field values'
    end
  end
end
