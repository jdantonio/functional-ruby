require 'spec_helper'

module Functional

  describe Tuple do

    context '#initialize' do

      it 'creates an empty tuple when given no arguments'

      it 'creates an empty tuple when given an empty array'

      it 'creates a tuple when given a single array argument'

      it 'creates a tuple when given a single argument that responds to #to_a'

      it 'freezes the tuple'
    end

    context '#at' do

      it 'returns the nth element when given a valid non-negative index'

      it 'returns the nth element from the end when given a valid negative index'

      it 'returns nil when given a non-negative out-of-bounds index'

      it 'returns nil when given a negative out-of-bounds index'

      it 'is aliased as #nth'

      it 'is aliased as #[]'
    end

    context '#fetch' do

      it 'returns the nth element when given a valid non-negative index'

      it 'returns the nth element from the end when given a valid negative index'

      it 'returns the given default when given a non-negative out-of-bounds index'

      it 'returns the given default when given a negative out-of-bounds index'
    end

    context '#length' do

      it 'returns 0 for an empty tuple'

      it 'returns the length of a non-empty tuple'

      it 'is aliased a #size'
    end

    context '#intersect' do

      it 'returns an empty tuple when self is empty'

      it 'returns an empty tuple when other is empty'

      it 'returns a tuple with all elements common to both tuples'

      it 'removes duplicates from self'

      it 'removes duplicates from other'

      it 'operates on any other that responds to #to_a'

      it 'is aliased as #&'
    end

    context '#union' do

      it 'returns a tuple with all elements from both tuples'

      it 'removes duplicates from self'

      it 'removes duplicates from other'

      it 'operates on any other that responds to #to_a'

      it 'is aliased as #|'
    end

    context '#concat' do

      it 'returns a copy of self when other is empty'

      it 'returns a copy of other when self is empty'

      it 'returns a new tuple containing all of self and other in order'

      it 'does not remove duplicates from self or other'

      it 'operates on any other that responds to #to_a'

      it 'is aliased as #+'
    end

    context '#diff' do

      it 'returns a copy of self when other is empty'

      it 'returns an empty tuple when self is empty'

      it 'returns an empty tuple when self and other have identical elements'

      it 'returns a tuple with all elements in self not also in other'

      it 'removes duplicates from self when in other'

      it 'operates on any other that responds to #to_a'

      it 'is aliased as #-'
    end

    context '#repeat' do

      it 'returns an empty tuple when multipled by zero'

      it 'returns a copy of self when multipled by one'

      it 'returns a tuple containing elements from self repeated n times'

      it 'is aliased as #*'
    end

    context '#uniq' do

      it 'returns a empty tuple when empty'

      it 'returns a copy of self when there are no duplicate elements'

      it 'returns a new tuple with duplicates removed'
    end

    context '#each' do

      it 'returns an Enumerable when no block given'

      it 'enumerates over each element'

      it 'does not call the block when empty'
    end

    context '#each_with_index' do

      it 'returns an Enumerable when no block given'

      it 'enumerates over each element and index pair'

      it 'does not call the block when empty'
    end

    context '#sequence' do

      it 'returns an Enumerable when no block given'

      it 'enumerates over each element and a tuple of the remaining elements'

      it 'yields an empty array for rest when on last element'

      it 'does not call the block when empty'
    end

    context '#eql?' do

      it 'returns true when compared to a tuple with identical elements'

      it 'returns false when given a tuple with different elements'

      it 'operates on any other that responds to #to_a'

      it 'is aliased as #=='
    end

    context '#empty?' do

      it 'returns true when there are no elements'

      it 'returns false when there are one or more elements'
    end

    context '#first' do

      it 'returns nil when empty'

      it 'returns the first element when not empty'

      it 'is aliased as #head'
    end

    context '#rest' do

      it 'returns an empty tuple when empty'

      it 'returns a tuple with all but the first element when not empty'

      it 'is aliased as #tail'
    end

    context '#to_a' do

      it 'returns an empty array when empty'

      it 'returns an array with the same elements as self'

      it 'is aliased as #to_ary'
    end

    context 'reflection' do

      specify '#inspect begins with the class name'

      specify '#inspect includes a list of all elements'

      specify '#to_s returns the same string an an array with the same elements'
    end
  end
end
