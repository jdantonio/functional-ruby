require 'spec_helper'

module Functional

  describe Catalog do

    let(:hash_sample) {
      {
        7  => 8,
        17 => 14,
        27 => 6,
        32 => 12,
        37 => 8,
        22 => 4,
        42 => 3,
        12 => 8,
        47 => 2
      }.freeze
    }

    let(:hash_sample_for_block) {
      {
        7  => {:count => 8},
        17 => {:count => 14},
        27 => {:count => 6},
        32 => {:count => 12},
        37 => {:count => 8},
        22 => {:count => 4},
        42 => {:count => 3},
        12 => {:count => 8},
        47 => {:count => 2}
      }.freeze
    }

    let(:catalog_sample) {
      [
        [7, 8],
        [17, 14],
        [27, 6],
        [32, 12],
        [37, 8],
        [22, 4],
        [42, 3],
        [12, 8],
        [47, 2]
      ].freeze
    }

    let(:catalog_sample_for_block) {
      [
        [7, {:count => 8}],
        [17, {:count => 14}],
        [27, {:count => 6}],
        [32, {:count => 12}],
        [37, {:count => 8}],
        [22, {:count => 4}],
        [42, {:count => 3}],
        [12, {:count => 8}],
        [47, {:count => 2}]
      ].freeze
    }

    context 'creation' do

      context '#initialize' do

        it 'creates an empty Catalog when no arguments are given' do
          catalog = Catalog.new
          catalog.should be_empty
        end

        it 'creates a Catalog from a hash' do
          catalog = Catalog.new(hash_sample, :from => :hash)
          catalog.size.should eq 9
        end

        it 'creates a Catalog from an array' do
          catalog = Catalog.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], :from => :array)
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]
        end

        it 'creates a Catalog from a catalog' do
          catalog = Catalog.new(catalog_sample, :from => :catalog)
          catalog.size.should eq 9
          catalog.first.should eq catalog_sample.first
          catalog.last.should eq catalog_sample.last

          catalog = Catalog.new(catalog_sample, :from => :catalogue)
          catalog.size.should eq 9
          catalog.first.should eq catalog_sample.first
          catalog.last.should eq catalog_sample.last
        end
        
        it 'assumes the arguments are a catalog when no :from is given' do
          catalog = Catalog.new(catalog_sample)
          catalog.size.should eq 9
          catalog.first.should eq catalog_sample.first
          catalog.last.should eq catalog_sample.last
        end

        it 'creates an empty Catalog when :from is unrecognized' do
          catalog = Catalog.new(hash_sample, :from => :bogus)
          catalog.should be_empty
        end

        it 'uses the given block to create key/value pairs' do
          sample = [
            {:x => 1, :y => 2},
            {:x => 3, :y => 4},
            {:x => 5, :y => 6}
          ]

          expected = [ [1, 2], [3, 4], [5, 6] ]

          catalog = Catalog.new(sample){|item| [ item[:x], item[:y] ] }
          catalog.should eq expected
        end
      end

      context '#from_array' do

        it 'creates a Catalog from an Array' do
          catalog = Catalog.from_array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]

          catalog = Catalog.from_array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]
        end

        it 'creates an empty Catalog from an empty Array' do
          catalog = Catalog.from_array([])
          catalog.should be_empty
        end

        it 'throws out the last element when given an odd-size array' do
          catalog = Catalog.from_array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
          catalog.size.should eq 5
          catalog.first.should eq [1, 2]
          catalog.last.should eq [9, 10]
        end

        it 'creates a Catalog when given an array and a block' do
          sample = [
            {:count => 13},
            {:count => 18},
            {:count => 13},
            {:count => 14},
            {:count => 13},
            {:count => 16},
            {:count => 14},
            {:count => 13}
          ].freeze

          catalog = Catalog.from_array(sample){|item| item[:count]}
          catalog.size.should eq 4
          catalog.first.should eq [13, 18]
          catalog.last.should eq [14, 13]
        end
      end

      context '#from_hash' do

        it 'creates a Catalog from a hash' do
          catalog = Catalog.from_hash(hash_sample)
          catalog.size.should eq 9

          catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
          catalog.size.should eq 3
        end

        it 'creates an empty Catalog from an empty hash' do
          catalog = Catalog.from_hash({})
          catalog.should be_empty
        end

        it 'creates a Catalog when given a hash and a block' do
          catalog = Catalog.from_hash(hash_sample_for_block){|item| item[:count]}
          catalog.size.should eq 9
        end
      end

      context '#from_catalog' do

        context 'creates a Catalog from a catalog' do

          specify do
            catalog = Catalog.from_catalog(catalog_sample)
            catalog.size.should eq 9
            catalog.first.should eq catalog_sample.first
            catalog.last.should eq catalog_sample.last
          end

          specify do
            catalog = Catalog.from_catalog([:one, 1], [:two, 2], [:three, 3])
            catalog.size.should eq 3
            catalog.first.should eq [:one, 1]
            catalog.last.should eq [:three, 3]
          end

          specify do
            catalog = Catalog.from_catalog([[:one, 1], [:two, 2], [:three, 3]])
            catalog.size.should eq 3
            catalog.first.should eq [:one, 1]
            catalog.last.should eq [:three, 3]
          end

          specify do
            catalog = Catalog.from_catalog([:one, 1], [:two, 2])
            catalog.size.should eq 2
            catalog.first.should eq [:one, 1]
            catalog.last.should eq [:two, 2]
          end

          specify do
            catalog = Catalog.from_catalog([[:one, 1], [:two, 2]])
            catalog.size.should eq 2
            catalog.first.should eq [:one, 1]
            catalog.last.should eq [:two, 2]
          end

          specify do
            catalog = Catalog.from_catalog([:one, 1])
            catalog.size.should eq 1
            catalog.first.should eq [:one, 1]
            catalog.last.should eq [:one, 1]
          end

          specify do
            catalog = Catalog.from_catalog([[:one, 1]])
            catalog.size.should eq 1
            catalog.first.should eq [:one, 1]
            catalog.last.should eq [:one, 1]
          end
        end

        it 'creates an empty Catalog from an empty catalog' do
          catalog = Catalog.from_catalog({})
          catalog.should be_empty
        end

        it 'creates a Catalog when given a catalog and a block' do
          catalog = Catalog.from_catalog(catalog_sample_for_block){|item| item[:count]}
          catalog.size.should eq 9
          catalog.first.should eq [catalog_sample.first[0], catalog_sample.first[1]]
          catalog.last.should eq [catalog_sample.last[0], catalog_sample.last[1]]
        end
      end
    end

    context '#==' do
      
      it 'returns true for equal catalogs' do
        catalog_1 = Catalog.from_hash(hash_sample)
        catalog_2 = Catalog.from_hash(hash_sample)
        catalog_1.should eq catalog_2
      end

      
      it 'returns false for unequal catalogs' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.from_hash(hash_sample)
        catalog_1.should_not eq catalog_2
      end

      it 'compares with an equal Catalog object' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_1.should == catalog_2
      end

      it 'compares with an equal catalog array' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = [[1, 1], [2, 2], [3, 3]]
        catalog_1.should == catalog_2
      end

      it 'compares with a non-equal Catalog objects' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[1, 1], [2, 2], [3, 3], [4, 4]])
        catalog_1.should_not == catalog_2
      end

      it 'compares with a non-equal catalog array' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = [[1, 1], [2, 2], [3, 3], [4, 4]]
        catalog_1.should_not == catalog_2
      end

      it 'returns false when compared with any other object' do
        Catalog.new.should_not == :foo
      end
    end

    context '#!=' do
      
      it 'returns false for equal catalogs' do
        catalog_1 = Catalog.from_hash(hash_sample)
        catalog_2 = Catalog.from_hash(hash_sample)
        (catalog_1 != catalog_2).should be_false
      end

      
      it 'returns true for unequal catalogs' do
        catalog_1 = Catalog.from_hash(hash_sample)
        catalog_2 = Catalog.new
        (catalog_1 != catalog_2).should be_true
      end

      it 'compares with an equal Catalog object' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        (catalog_1 != catalog_2).should be_false
      end

      it 'compares with an equal catalog array' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = [[1, 1], [2, 2], [3, 3]]
        (catalog_1 != catalog_2).should be_false
      end

      it 'compares with a non-equal Catalog objects' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[1, 1], [2, 2], [3, 3], [4, 4]])
        (catalog_1 != catalog_2).should be_true
      end

      it 'compares with a non-equal catalog array' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = [[1, 1], [2, 2], [3, 3], [4, 4]]
        (catalog_1 != catalog_2).should be_true
      end

      it 'returns true when compared with any other object' do
        (Catalog.new != :foo).should be_true
      end
    end

    context '<=>' do

      let(:low) { [[1, 1], [2, 2]] }
      let(:high) { [[3, 3], [4, 4]] }

      it 'returns a negative number when less than another Catalog' do
        small = Catalog.new(low)
        big = Catalog.new(high)
        (small <=> big).should < 0
      end

      it 'returns a negative number when less than a catalog' do
        small = Catalog.new(low)
        (small <=> high).should < 0
      end

      it 'returns zero when equal to another Catalog' do
        small = Catalog.new(low)
        big = Catalog.new(low)
        (small <=> big).should eq 0
      end

      it 'returns zero when equal to a catalog' do
        small = Catalog.new(low)
        (small <=> low).should eq 0
      end

      it 'returns a positive number when greater than another Catalog' do
        small = Catalog.new(low)
        big = Catalog.new(high)
        (big <=> small).should > 0
      end

      it 'returns a positive number when greater than a catalog' do
        big = Catalog.new(high)
        (big <=> low).should > 0
      end

      it 'raises an error when compated to an invalid object' do
        lambda {
          Catalog.new <=> :foo
        }.should raise_error(TypeError)
      end
    end

    context '#[]' do

      it 'returns nil when empty' do
        catalog = Catalog.new
        catalog[0].should be_nil
      end

      it 'returns the element at a valid positive index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[0].should eq catalog_sample[0]
      end

      it 'returns the element at a valid negative index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[-1].should eq catalog_sample[-1]
      end

      it 'returns nil for an invalid positive index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[100].should be_nil
      end

      it 'returns nil for an invalid negative index' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog[-100].should be_nil
      end
    end

    context '#[]=' do

      let(:catalog) { Catalog.from_hash(:one => 1, :two => 2, :three => 3) }

      it 'accepts a one-element hash as a value' do
        catalog[0] = {:foo => :bar}
        catalog[0].should eq [:foo, :bar]
      end

      it 'accepts a two-element array as a value' do
        catalog[0] = [:foo, :bar]
        catalog[0].should eq [:foo, :bar]
      end

      it 'raises an exception when given in invalid value' do
        lambda {
          catalog[0] = :foo
        }.should raise_error(ArgumentError)
      end

      it 'updates the index when given a valid positive index' do
        catalog[1] = [:foo, :bar]
        catalog.should eq [[:one, 1], [:foo, :bar], [:three, 3]]
      end

      it 'updates the index when given an invalid negative index' do
        catalog[-2] = [:foo, :bar]
        catalog.should eq [[:one, 1], [:foo, :bar], [:three, 3]]
      end

      it 'raises an exception when given an invalid positive index' do
        lambda {
          catalog[100] = [:foo, :bar]
        }.should raise_error(ArgumentError)
      end

      it 'raises an exception when given an invalid negative index' do
        lambda {
          catalog[-100] = [:foo, :bar]
        }.should raise_error(ArgumentError)
      end

    end

    context '#&' do

      it 'returns a new Catalog object' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.new
        intersection = catalog_1 & catalog_2
        intersection.object_id.should_not eq catalog_1.object_id
        intersection.object_id.should_not eq catalog_2.object_id
      end

      it 'intersects two empty Catalogs' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.new
        intersection = catalog_1 & catalog_2
        intersection.should be_empty
      end

      it 'intersects an empty Catalog with a non-empty Catalog' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new
        intersection = catalog_1 & catalog_2
        intersection.should be_empty
      end

      it 'intersects two non-empty Catalogs' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[2, 2], [3, 3], [4, 4], [5, 5]])
        intersection = catalog_1 & catalog_2
        intersection.should eq [[2, 2], [3, 3]]
      end

      it 'intersects a Catalog object with a catalog' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = [[2, 2], [3, 3], [4, 4], [5, 5]]
        intersection = catalog_1 & catalog_2
        intersection.should eq [[2, 2], [3, 3]]
      end

      it 'removes duplicates when intersecting two non-empty Catalogs' do
        catalog_1 = Catalog.new([[1, 1], [1, 1], [1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[1, 1], [3, 3], [4, 4], [5, 5]])
        intersection = catalog_1 & catalog_2
        intersection.should eq [[1, 1], [3, 3]]
      end

      it 'raises an error when given a non-Catalog object' do
        lambda {
          catalog_1 = Catalog.new([[1, 1], [1, 1], [1, 1], [2, 2], [3, 3]])
          intersection = catalog_1 & :foo
        }.should raise_error(TypeError)
      end
    end

    context '#+' do

      it 'returns a new Catalog object' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.new
        sum = catalog_1 + catalog_2
        sum.object_id.should_not eq catalog_1.object_id
        sum.object_id.should_not eq catalog_2.object_id
      end

      it 'adds two empty Catalogs' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.new
        sum = catalog_1 + catalog_2
        sum.should be_empty
      end

      it 'adds an empty Catalog with a non-empty Catalog' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new
        sum = catalog_1 + catalog_2
        sum.should eq [[1, 1], [2, 2], [3, 3]]
      end

      it 'adds two non-empty Catalogs' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[2, 2], [3, 3], [4, 4], [5, 5]])
        sum = catalog_1 + catalog_2
        sum.should eq [[1, 1], [2, 2], [3, 3], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'adds a Catalog object with a catalog' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = [[2, 2], [3, 3], [4, 4], [5, 5]]
        sum = catalog_1 + catalog_2
        sum.should eq [[1, 1], [2, 2], [3, 3],[2, 2], [3, 3], [4, 4], [5, 5] ]
      end

      it 'raises an error when given a non-Catalog object' do
        lambda {
          catalog_1 = Catalog.new([[1, 1], [1, 1], [1, 1], [2, 2], [3, 3]])
          sum = catalog_1 + :foo
        }.should raise_error(TypeError)
      end
    end

    context '#|' do
 
      it 'returns a new Catalog object' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.new
        union = catalog_1 | catalog_2
        union.object_id.should_not eq catalog_1.object_id
        union.object_id.should_not eq catalog_2.object_id
      end

      it 'unions two empty Catalogs' do
        catalog_1 = Catalog.new
        catalog_2 = Catalog.new
        union = catalog_1 | catalog_2
        union.should be_empty
      end

      it 'unions an empty Catalog with a non-empty Catalog' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new
        union = catalog_1 | catalog_2
        union.should eq [[1, 1], [2, 2], [3, 3]]
      end

      it 'unions two non-empty Catalogs' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[4, 4], [5, 5]])
        union = catalog_1 | catalog_2
        union.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'unions a Catalog object with a catalog' do
        catalog_1 = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog_2 = [[4, 4], [5, 5]]
        union = catalog_1 | catalog_2
        union.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'removes duplicates when intersecting two non-empty Catalogs' do
        catalog_1 = Catalog.new([[1, 1], [1, 1], [1, 1], [2, 2], [3, 3]])
        catalog_2 = Catalog.new([[1, 1], [3, 3], [4, 4], [5, 5]])
        union = catalog_1 | catalog_2
        union.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'raises an error when given a non-Catalog object' do
        lambda {
          catalog_1 = Catalog.new([[1, 1], [1, 1], [1, 1], [2, 2], [3, 3]])
          union = catalog_1 | :foo
        }.should raise_error(TypeError)
      end   
    end

    context '#push' do

      it 'returns the Catalog' do
        catalog_1 = Catalog.new
        catalog_2 = catalog_1.push([1, 2])
        catalog_1.object_id.should eq catalog_2.object_id
      end

      it 'appends a two-element array onto the catalog' do
        catalog = Catalog.new([[1, 1], [2, 2]])
        catalog = catalog.push([3, 3])
        catalog.should eq [[1, 1], [2, 2], [3, 3]]
      end

      it 'appends a one-element hash onto the catalog' do
        catalog = Catalog.new([[1, 1], [2, 2]])
        catalog = catalog.push({3 => 3})
        catalog.should eq [[1, 1], [2, 2], [3, 3]]
      end

      it 'raises an error for an invalid datatype' do
        lambda {
          Catalog.new.push(:foo)
        }.should raise_error(TypeError)
      end
    end

    context '#pop' do

      it 'returns nil when empty' do
        Catalog.new.pop.should be_nil
      end

      it 'returns the last element' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        pop = catalog.pop
        pop.should eq [3, 3]
      end

      it 'removes the last element' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.pop
        catalog.should eq [[1, 1], [2, 2]]
      end
    end

    context '#peek' do

      it 'returns nil when empty' do
        Catalog.new.peek.should be_nil
      end

      it 'returns the last element' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        peek = catalog.pop
        peek.should eq [3, 3]
      end

      it 'does not remove the last element' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.peek
        catalog.should eq [[1, 1], [2, 2], [3, 3]]
      end
    end

    context '#keys' do

      it 'returns an empty array when empty' do
        Catalog.new.keys.should be_empty
      end

      it 'returns an array with all first elements in the catalog' do
        catalog = Catalog.new([[0, 0], [0, 1], [1, 0], [1, 1], [2, 2], [3, 3]])
        keys = catalog.keys
        keys.should eq [0, 0, 1, 1, 2, 3]
      end
    end

    context '#values' do

      it 'returns an empty array when empty' do
        Catalog.new.values.should be_empty
      end

      it 'returns an array with all last elements in the catalog' do
        catalog = Catalog.new([[0, 0], [0, 1], [1, 0], [1, 1], [2, 2], [3, 3]])
        values = catalog.values
        values.should eq [0, 1, 0, 1, 2, 3]
      end
    end

    context '#first' do

      it 'returns nil when empty' do
        Catalog.new.first.should be_nil
      end

      it 'returns the first element when not empty' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog.first.should == catalog_sample.first
      end
    end

    context '#last' do

      it 'returns nil when empty' do
        Catalog.new.last.should be_nil
      end

      it 'returns the last element when not empty' do
        catalog = Catalog.from_catalog(catalog_sample)
        catalog.last.should == catalog_sample.last
      end
    end

    context '#iterators' do

      let(:sample) {
        [
          [7, 8],
          [17, 14],
          [27, 6],
          [32, 12],
          [37, 8],
          [22, 4],
          [42, 3],
          [12, 8],
          [47, 2]
        ].freeze
      }

      let(:catalog) { Catalog.new(sample) }

      specify '#each' do

        index = 0
        catalog.each do |item|
          item.should eq sample[index]
          index = index + 1
        end
      end

      specify '#each_pair' do

        index = 0
        catalog.each_pair do |key, value|
          key.should eq sample[index].first
          value.should eq sample[index].last
          index = index + 1
        end
      end

      specify '#each_key' do

        index = 0
        catalog.each_key do |key|
          key.should eq sample[index].first
          index = index + 1
        end
      end

      specify '#each_value' do

        index = 0
        catalog.each_value do |value|
          value.should eq sample[index].last
          index = index + 1
        end
      end
    end

    context '#empty?' do

      it 'returns true when empty' do
        catalog = Catalog.new
        catalog.should be_empty
      end

      it 'returns false when not empty' do
        catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
        catalog.should_not be_empty
      end
    end

    context '#include?' do

      it 'returns false when empty' do
        Catalog.new.include?([1, 1]).should be_false
      end

      it 'returns true when the key/value array is found' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.include?([2, 2]).should be_true
      end

      it 'returns true when the key/value pair is found' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.include?(2, 2).should be_true
      end

      it 'returns true for given a one-element hash that matches' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.include?({2 => 2}).should be_true
      end

      it 'returns true for an implicit one-element hash that matches' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.include?(2 => 2).should be_true
      end

      it 'returns false when not found' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.include?([4, 4]).should be_false
      end

      it 'returns false when given an invalid lookup item' do
        catalog = Catalog.new([[1, 1], [2, 2], [3, 3]])
        catalog.include?(:foo).should be_false
      end
    end

    context '#size' do

      it 'returns zero when is empty' do
        catalog = Catalog.new
        catalog.size.should eq 0
      end

      it 'returns the correct positive integer when not empty' do
        catalog = Catalog.from_hash(:one => 1, :two => 2, :three => 3)
        catalog.size.should eq 3
      end
    end

    context '#slice' do

      let(:catalog) {
        Catalog.new([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]])
      }

      it 'returns the element at index' do
        slice = catalog.slice(2)
        slice.should eq [[3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'returns the elements from index through length' do
        slice = catalog.slice(1, 2)
        slice.should eq [[2, 2], [3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'returns a catalog specified by range' do
        slice = catalog.slice(1..2)
        slice.should eq [[2, 2], [3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'returns the element at the negative index' do
        slice = catalog.slice(-3)
        slice.should eq [[3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end

      it 'returns an empty Catalog if the index is out of range' do
        slice = catalog.slice(10, 2)
        slice.should be_empty
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end
    end

    context '#slice!' do

      let(:catalog) {
        Catalog.new([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]])
      }

      it 'returns the element at index' do
        slice = catalog.slice!(2)
        slice.should eq [[3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [4, 4], [5, 5]]
      end

      it 'returns the elements from index through length' do
        slice = catalog.slice!(1, 2)
        slice.should eq [[2, 2], [3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [4, 4], [5, 5]]
      end

      it 'returns a catalog specified by range' do
        slice = catalog.slice!(1..2)
        slice.should eq [[2, 2], [3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [4, 4], [5, 5]]
      end

      it 'returns the element at the negative index' do
        slice = catalog.slice!(-3)
        slice.should eq [[3, 3]]
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [4, 4], [5, 5]]
      end

      it 'returns an empty Catalog if the index is out of range' do
        slice = catalog.slice!(10, 2)
        slice.should be_empty
        slice.should be_a Catalog
        catalog.should eq [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
      end
    end

    context 'sorting' do

      let(:unsorted_catalog) {
        [
          [7, 8],
          [17, 14],
          [27, 6],
          [32, 12],
          [37, 9],
          [22, 4],
          [42, 3],
          [12, 10],
          [47, 2]
        ].freeze
      }

      let(:catalog_sorted_by_key) {
        [
          [7, 8],
          [12, 10],
          [17, 14],
          [22, 4],
          [27, 6],
          [32, 12],
          [37, 9],
          [42, 3],
          [47, 2]
        ].freeze
      }

      let(:catalog_sorted_by_value) {
        [
          [47, 2],
          [42, 3],
          [22, 4],
          [27, 6],
          [7, 8],
          [37, 9],
          [12, 10],
          [32, 12],
          [17, 14]
        ].freeze
      }

      let(:catalog_reversed) {
        [
          [47, 2],
          [42, 3],
          [37, 9],
          [32, 12],
          [27, 6],
          [22, 4],
          [17, 14],
          [12, 10],
          [7, 8]
        ].freeze
      }

      let(:catalog) { Catalog.new(unsorted_catalog) }

      specify '#sort_by_key' do
        sorted = catalog.sort_by_key
        sorted.should eq catalog_sorted_by_key
        catalog.should eq unsorted_catalog
        sorted.should be_a Catalog
      end

      specify '#sort_by_key!' do
        sorted = catalog.sort_by_key!
        sorted.should eq catalog_sorted_by_key
        catalog.should eq catalog_sorted_by_key
        sorted.object_id.should eq catalog.object_id
      end

      specify '#sort_by_value' do
        sorted = catalog.sort_by_value
        sorted.should eq catalog_sorted_by_value
        catalog.should eq unsorted_catalog
        sorted.should be_a Catalog
      end

      specify '#sort_by_value!' do
        sorted = catalog.sort_by_value!
        sorted.should eq catalog_sorted_by_value
        catalog.should eq catalog_sorted_by_value
        sorted.object_id.should eq catalog.object_id
      end

      specify '#sort' do
        sorted = catalog.sort
        sorted.should eq catalog_sorted_by_key
        catalog.should eq unsorted_catalog
        sorted.should be_a Catalog
      end

      specify '#sort!' do
        sorted = catalog.sort!
        sorted.should eq catalog_sorted_by_key
        catalog.should eq catalog_sorted_by_key
        sorted.object_id.should eq catalog.object_id
      end

      specify '#sort with block' do
        sorted = catalog.sort{|a, b| b <=> a}
        sorted.should eq catalog_reversed
        catalog.should eq unsorted_catalog
        sorted.should be_a Catalog
      end

      specify '#sort! with block' do
        sorted = catalog.sort!{|a, b| b <=> a}
        sorted.should eq catalog_reversed
        catalog.should eq catalog_reversed
        sorted.should be_a Catalog
      end
    end

    context 'conversion' do

      let(:sample) {
        [
          [7, 8],
          [17, 14],
          [47, 2]
        ].freeze
      }

      let(:sample_as_hash) {
        {
          7 => 8,
          17 => 14,
          47 => 2
        }.freeze
      }

      let(:sample_as_array) {
        [7, 8, 17, 14, 47, 2]
      }

      let(:catalog) { Catalog.new(sample) }

      context '#to_a' do

        specify { Catalog.new.to_a.should eq [] }

        specify { catalog.to_a.should eq sample_as_array }
      end

      context '#to_hash' do

        specify { Catalog.new.to_hash.should == {} }

        specify { catalog.to_hash.should eq sample_as_hash }
      end

      context '#to_catalog' do
        specify { Catalog.new.to_catalog.should eq [] }

        specify do
          cat = catalog.to_catalog
          cat.should eq sample
          cat.should be_a Array
        end
      end

      context '#to_s' do

        specify { Catalog.new.to_s.should eq '[]' }
        specify { Catalog.from_hash(:one => 1, :two => 2).to_s.should eq '[[:one, 1], [:two, 2]]' }
      end
    end

    context 'deletion' do

      let(:sample) {
        [
          [7, 8],
          [17, 14],
          [47, 2]
        ].freeze
      }

      let(:catalog) { Catalog.new(sample) }

      context 'delete' do

        it 'deletes the specified item' do
          item = catalog.delete([17, 14])
          item.should eq [17, 14]
          catalog.should eq [[7, 8], [47, 2]]
        end

        it 'deletes the item matching the given key/value pair' do
          item = catalog.delete(17, 14)
          item.should eq [17, 14]
          catalog.should eq [[7, 8], [47, 2]]
        end

        it 'deletes the item matching the given one-item hash' do
          item = catalog.delete({17 => 14})
          item.should eq [17, 14]
          catalog.should eq [[7, 8], [47, 2]]
        end

        it 'deletes the item matching the implied one-item hash' do
          item = catalog.delete(17 => 14)
          item.should eq [17, 14]
          catalog.should eq [[7, 8], [47, 2]]
        end

        it 'returns nil if the item is not found' do
          item = catalog.delete([1, 2])
          item.should be_nil
        end

        it 'returns the result of the given block if the item is not found' do
          item = catalog.delete([1, 2]){ 'not found' }
          item.should eq 'not found'
        end
      end

      context 'delete_at' do

        it 'deletes the item at the specified index' do
          item = catalog.delete_at(1)
          item.should eq [17, 14]
          catalog.should eq [[7, 8], [47, 2]]
        end

        it 'returns nil if the index is out of range' do
          item = catalog.delete_at(100)
          item.should be_nil
        end

        it 'returns the result of the given block if the index is out of range' do
          item = catalog.delete_at(100){ 'not found' }
          item.should eq 'not found'
        end
      end

      context 'delete_if' do

        it 'can yield the key/value pair on iteration' do
          catalog.delete_if {|item| item.last > 5}
          catalog.should eq [[47, 2]]
        end

        it 'can yield the key and value separately on iteration' do
          catalog.delete_if {|key, value| value > 5}
          catalog.should eq [[47, 2]]
        end

        it 'removes the matched items' do
          catalog.delete_if {|key, value| value > 5}
          catalog.should eq [[47, 2]]
        end

        it 'does nothing on no matches' do
          result = catalog.delete_if {|item| false }
          result.should eq catalog
        end

        it 'returns self' do
          result = catalog.delete_if {|key, value| value > 5}
          result.object_id.should eq catalog.object_id
        end

        it 'raises an exception if a block is not given' do
          lambda {
            catalog.delete_if
          }.should raise_error(ArgumentError)
        end
      end
    end
  end
end
