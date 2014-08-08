require 'spec_helper'
require 'rspec/expectations'

RSpec::Matchers.define :be_a_different_tuple_than do |expected|
  match do |actual|
    actual.is_a?(Functional::Tuple) && actual.object_id != expected.object_id
  end
end

module Functional

  describe Tuple do

    context '#initialize' do

      it 'creates an empty tuple when given no arguments' do
        expect(Tuple.new).to be_empty
      end

      it 'creates an empty tuple when given an empty array' do
        expect(Tuple.new([])).to be_empty
      end

      it 'creates a tuple when given a single array argument' do
        subject = Tuple.new[:foo, :bar, :baz]

        expect(subject).to_not be_empty
        expect(subject[0]).to eq :foo
        expect(subject[1]).to eq :bar
        expect(subject[2]).to eq :baz
      end

      it 'creates a tuple when given a single argument that responds to #to_a' do
        subject = Class.new {
          def to_a() [:foo, :bar, :baz]; end
        }.new

        expect(subject).to_not be_empty
        expect(subject[0]).to eq :foo
        expect(subject[1]).to eq :bar
        expect(subject[2]).to eq :baz
      end

      it 'raises an exception when given a non-array argument' do
        expect {
          Tuple.new(:foo)
        }.to raise_error(ArgumentError)
      end

      it 'freezes the tuple' do
        expect(Tuple.new).to be_frozen
        expect(Tuple.new([])).to be_frozen
        expect(Tuple.new([:foo, :bar, :baz])).to be_frozen
      end
    end

    context '#at' do

      subject { Tuple.new([:foo, :bar, :baz]) }

      it 'returns the nth element when given a valid non-negative index' do
        expect(subject.at(0)).to eq :foo
        expect(subject.at(1)).to eq :bar
        expect(subject.at(2)).to eq :baz
      end

      it 'returns the nth element from the end when given a valid negative index' do
        expect(subject.at(-1)).to eq :foo
        expect(subject.at(-2)).to eq :bar
        expect(subject.at(-3)).to eq :baz
      end

      it 'returns nil when given a non-negative out-of-bounds index' do
        expect(subject.at(3)).to be_nil
      end

      it 'returns nil when given a negative out-of-bounds index' do
        expect(subject.at(-4)).to be_nil
      end

      it 'is aliased as #nth' do
        expect(subject.nth(0)).to eq :foo
        expect(subject.nth(1)).to eq :bar
        expect(subject.nth(-2)).to eq :bar
        expect(subject.nth(-3)).to eq :baz
      end

      it 'is aliased as #[]' do
        expect(subject[0]).to eq :foo
        expect(subject[1]).to eq :bar
        expect(subject[-2]).to eq :bar
        expect(subject[-3]).to eq :baz
      end
    end

    context '#fetch' do

      subject { Tuple.new([:foo, :bar, :baz]) }

      it 'returns the nth element when given a valid non-negative index' do
        expect(subject.fetch(0, 42)).to eq :foo
        expect(subject.fetch(1, 42)).to eq :bar
        expect(subject.fetch(2, 42)).to eq :baz
      end

      it 'returns the nth element from the end when given a valid negative index' do
        expect(subject.fetch(-1, 42)).to eq :foo
        expect(subject.fetch(-2, 42)).to eq :bar
        expect(subject.fetch(-3, 42)).to eq :baz
      end

      it 'returns the given default when given a non-negative out-of-bounds index' do
        expect(subject.at(3, 42)).to eq 42
      end

      it 'returns the given default when given a negative out-of-bounds index' do
        expect(subject.at(-4, 42)).to eq 42
      end
    end

    context '#length' do

      it 'returns 0 for an empty tuple' do
        expect(Tuple.new.length).to eq 0
      end

      it 'returns the length of a non-empty tuple' do
        expect(Tuple.new(1, 2, 3).length).to eq 3
      end

      it 'is aliased a #size' do
        expect(Tuple.new.size).to eq 0
        expect(Tuple.new(1, 2, 3).size).to eq 3
      end
    end

    context '#intersect' do

      it 'returns an empty tuple when self is empty' do
        subject = Tuple.new
        other = Tuple.new([1, 2, 3])
        result = subject.intersect(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to be_empty
      end

      it 'returns an empty tuple when other is empty' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new
        result = subject.intersect(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to be_empty
      end

      it 'returns a tuple with all elements common to both tuples' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([2, 3, 4])
        result = subject.intersect(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [2, 3]
      end

      it 'removes duplicates from self' do
        subject = Tuple.new([1, 2, 2, 3, 3, 3])
        other = Tuple.new([2, 3, 4])
        result = subject.intersect(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [2, 3]
      end

      it 'removes duplicates from other' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([2, 2, 3, 3, 3, 4])
        result = subject.intersect(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [2, 3]
      end

      it 'operates on any other that responds to #to_a' do
        subject = Tuple.new([1, 2, 3])
        other = Class.new {
          def to_a() [2, 3, 4]; end
        }.new

        result = subject.intersect(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [2, 3]
      end

      it 'is aliased as #&' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([2, 3, 4])
        result = subject & other
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [2, 3]
      end
    end

    context '#union' do

      it 'returns a copy of self when other is empty' do
        subject = Tuple.new
        other = Tuple.new([1, 2, 3])
        result = subject.union(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3]
      end

      it 'returns a copy of other when self is empty' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new
        result = subject.union(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3]
      end

      it 'returns a tuple with all elements from both tuples' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([1, 2, 3])
        result = subject.union(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3, 4]
      end

      it 'removes duplicates from self' do
        subject = Tuple.new([1, 2, 2, 3, 3, 3])
        other = Tuple.new([1, 2, 3])
        result = subject.union(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3, 4]
      end

      it 'removes duplicates from other' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([1, 2, 2, 3, 3, 3])
        result = subject.union(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3, 4]
      end

      it 'operates on any other that responds to #to_a' do
        subject = Tuple.new([1, 2, 3])
        other = Class.new {
          def to_a() [2, 3, 4]; end
        }.new

        result = subject.union(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3, 4]
      end

      it 'is aliased as #|' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([2, 3, 4])
        result = subject | other
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3, 4]
      end
    end

    context '#concat' do

      it 'returns a copy of self when other is empty' do
        subject = Tuple.new
        other = Tuple.new([1, 2, 3])
        result = subject.concat(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3]
      end

      it 'returns a copy of other when self is empty' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new
        result = subject.concat(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3]
      end

      it 'returns a new tuple containing all of self and other in order' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([4, 5, 6])
        result = subject.concat(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3, 4, 5, 6]
      end

      it 'does not remove duplicates from self or other' do
        subject = Tuple.new([1, 2, 2, 3, 3, 3])
        other = Tuple.new([4, 4, 4, 5, 5, 6])
        result = subject.concat(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6]
      end

      it 'operates on any other that responds to #to_a' do
        subject = Tuple.new([1, 2, 3])
        other = Class.new {
          def to_a() [4, 5, 6]; end
        }.new

        result = subject.concat(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3, 4, 5, 6]
      end

      it 'is aliased as #+' do
        subject = Tuple.new([1, 2, 2, 3, 3, 3])
        other = Tuple.new([4, 4, 4, 5, 5, 6])
        result = subject + other
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6]
      end
    end

    context '#diff' do

      it 'returns a copy of self when other is empty' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new
        result = subject.diff(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3]
      end

      it 'returns an empty tuple when self is empty' do
        subject = Tuple.new
        other = Tuple.new([1, 2, 3])
        result = subject.diff(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to be_empty
      end

      it 'returns an empty tuple when self and other have identical elements' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([1, 2, 3])
        result = subject.diff(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to be_empty
      end

      it 'returns a tuple with all elements in self not also in other' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([3, 4, 5])
        result = subject.diff(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2]
      end

      it 'removes duplicates from self when in other' do
        subject = Tuple.new([1, 2, 3, 3, 3])
        other = Tuple.new([3, 4, 5])
        result = subject.diff(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2]
      end

      it 'removes duplicates from other when in self' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([3, 3, 3, 4, 5])
        result = subject.diff(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2]
      end

      it 'operates on any other that responds to #to_a' do
        subject = Tuple.new([1, 2, 3])
        other = Class.new {
          def to_a() [3, 4, 5]; end
        }.new

        result = subject.diff(other)
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2]
      end

      it 'is aliased as #-' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([3, 4, 5])
        result = subject - other
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2]
      end
    end

    context '#repeat' do

      it 'returns an empty tuple when multipled by zero' do
        subject = [1, 2, 3]
        result = subject.repeat(0)
        expect(result).to be_a_different_tuple_than(subject)
        expect(subject).to be_empty
      end

      it 'returns a copy of self when multipled by one' do
        subject = [1, 2, 3]
        result = subject.repeat(1)
        expect(result).to be_a_different_tuple_than(subject)
        expect(subject).to eq [1, 2, 3]
      end

      it 'returns a tuple containing elements from self repeated n times' do
        subject = [1, 2, 3]
        result = subject.repeat(3)
        expect(result).to be_a_different_tuple_than(subject)
        expect(subject).to eq [1, 2, 3, 1, 2, 3, 1, 2, 3]
      end

      it 'is aliased as #*' do
        subject = [1, 2, 3]
        result = subject * 3
        expect(result).to be_a_different_tuple_than(subject)
        expect(subject).to eq [1, 2, 3, 1, 2, 3, 1, 2, 3]
      end
    end

    context '#uniq' do

      it 'returns a empty tuple when empty' do
        subject = Tuple.new
        result = subject.uniq
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to be_empty
      end

      it 'returns a copy of self when there are no duplicate elements' do
        subject = Tuple.new([1, 2, 3])
        result = subject.uniq
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3]
      end

      it 'returns a new tuple with duplicates removed' do
        subject = Tuple.new([1, 2, 2, 3, 3, 3])
        result = subject.uniq
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq [1, 2, 3]
      end
    end

    context '#each' do

      it 'returns an Enumerable when no block given' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.each).to be_a Enumerable
      end

      it 'enumerates over each element' do
        result = []
        subject = Tuple.new(1, 2, 2, 3, 3, 3)
        subject.each{|item| result << item }
        expect(result).to eq [1, 2, 2, 3, 3, 3]
      end

      it 'does not call the block when empty' do
        result = false
        Tuple.each{|item| expected = true}
        expect(result).to be false
      end
    end

    context '#each_with_index' do

      it 'returns an Enumerable when no block given' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.each_with_index).to be_a Enumerable
      end

      it 'enumerates over each element and index pair' do
        result = {}
        subject = Tuple.new([1, 2, 2, 3, 3, 3])
        subject.each_with_index{|item, index| result[index] = item }

        expected = {
          0 => 1,
          1 => 2,
          2 => 2,
          3 => 3,
          4 => 3,
          5 => 3,
        }
        expect(result).to eq expected
      end

      it 'does not call the block when empty' do
        result = false
        Tuple.each_with_index{|item, index| expected = true}
        expect(result).to be false
      end
    end

    context '#sequence' do

      it 'returns an Enumerable when no block given' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.sequence).to be_a Enumerable
      end

      it 'enumerates over each element' do
        result = []
        subject = Tuple.new([1, 2, 2, 3, 3, 3])
        subject.sequence{|item, rest| result << item }
        expect(result).to eq [1, 2, 2, 3, 3, 3]
      end

      it 'yields rest of tuple for each element' do
        result = []
        subject = Tuple.new([1, 2, 3, 4])
        subject.sequence{|item, rest| result = rest; break }
        expect(result).to eq [2, 3, 4]
      end

      it 'yields rest of tuple as a tuple' do
        result = []
        subject = Tuple.new([1, 2, 3, 4])
        subject.sequence{|item, rest| result = rest; break }
        expect(result).to be_a_different_tuple_than(subject)
      end

      it 'yields an empty tuple for rest when on last element' do
        result = nil
        subject = Tuple.new([1])
        subject.sequence{|item, rest| result = rest }
        expect(result).to be_a_different_tuple_than(subject)
        expect(result).to eq []
      end

      it 'does not call the block when empty' do
        result = false
        Tuple.sequence{|item, rest| expected = true}
        expect(result).to be false
      end
    end

    context '#eql?' do

      it 'returns true when compared to a tuple with identical elements' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([1, 2, 3])
        expect(subject.eql?(other)).to be true
      end

      it 'returns false when given a tuple with different elements' do
        subject = Tuple.new([1, 2, 3])
        other = Tuple.new([2, 3, 4])
        expect(subject.eql?(other)).to be false
      end

      it 'operates on any other that responds to #to_a' do
        subject = Tuple.new([1, 2, 3])
        other = Class.new {
          def to_a() [1, 2, 3]; end
        }.new

        expect(subject.eql?(other)).to be true
      end

      it 'is aliased as #==' do
        subject = Tuple.new([1, 2, 3])
        identical = Tuple.new([1, 2, 3])
        different = Tuple.new([2, 3, 4])

        expect(subject == identical).to be true
        expect(subject == different).to be false
      end
    end

    context '#empty?' do

      it 'returns true when there are no elements' do
        subject = Tuple.new
        expect(subject.empty?).to be true
      end

      it 'returns false when there are one or more elements' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.empty?).to be false
      end
    end

    context '#first' do

      it 'returns nil when empty' do
        subject = Tuple.new
        expect(subject.first).to be nil
      end

      it 'returns the first element when not empty' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.first).to eq 1
      end

      it 'is aliased as #head' do
        expect(Tuple.new.head).to be nil
        expect(Tuple.new([1, 2, 3]).head).to eq 1
      end
    end

    context '#rest' do

      it 'returns an empty tuple when empty' do
        subject = Tuple.new
        expect(subject.rest).to be_a_different_tuple_than(subject)
        expect(subject.rest).to be_empty
      end

      it 'returns a tuple with all but the first element when not empty' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.rest).to be_a_different_tuple_than(subject)
        expect(subject.rest).to eq [2, 3]
      end

      it 'is aliased as #tail' do
        expect(Tuple.new.rest).to be_a_different_tuple_than(subject)
        expect(Tuple.new.rest).to be_empty
        expect(Tuple.new([1, 2, 3]).rest).to be_a_different_tuple_than(subject)
        expect(Tuple.new([1, 2, 3]).rest).to eq [2, 3]
      end
    end

    context '#to_a' do

      it 'returns an empty array when empty' do
        subject = Tuple.new.to_a
        expect(subject).to be_a Array
        expect(subject).to be_empty
      end

      it 'returns an array with the same elements as self' do
        subject = Tuple.new([1, 2, 3]).to_a
        expect(subject).to be_a Array
        expect(subject).to [1, 2, 3]
      end

      it 'returns a non-frozen array' do
        expect(Tuple.new.to_a).to_not be_frozen
        expect(Tuple.new([1, 2, 3]).to_a).to be_frozen
      end

      it 'is aliased as #to_ary' do
        subject = Tuple.new([1, 2, 3]).to_ary
        expect(subject).to be_a Array
        expect(subject).to [1, 2, 3]
      end
    end

    context 'reflection' do

      specify '#inspect begins with the class name' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.inspect).to match(/^#<#{described_class}:\s+/)
      end

      specify '#inspect includes a list of all elements' do
        subject = Tuple.new([1, 2, 3])
        expect(subject.inspect).to match(/\s+\[1, 2, 3\]>$/)
        expect(Tuple.new.inspect).to match(/\s+\[\]>$/)
      end

      specify '#to_s returns the same string an an array with the same elements' do
        expect(Tuple.new.to_s).to eq [].to_s
        expect(Tuple.new([1, 2, 3]).to_s).to eq [1, 2, 3].to_s
      end
    end
  end
end
