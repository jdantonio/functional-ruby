require 'spec_helper'

module Functional

  describe Collection do

    context '#random_sample' do

      specify { Collection.random_sample(100).length == 100 }
      specify { Collection.random_sample(100, :min => 10).min >= 10 }
      specify { Collection.random_sample(100, :max => 10).max >= 10 }

    end

    context 'bisection' do

      context '#bisect_left' do

        it 'returns nil when the sample is nil' do
          Collection.bisect_left(nil, 10).should be_nil
        end

        it 'returns zero when the sample is empty' do
          Collection.bisect_left([], 10).should eq 0
        end

        it 'returns the index when the item is not in the sample' do
          sample = [10, 20, 30]
          Collection.bisect_left(sample, 15).should eq 1
          Collection.bisect_left(sample, 25).should eq 2
        end

        it 'returns the index when the item is in the sample' do
          sample = [10, 20, 30]
          Collection.bisect_left(sample, 10).should eq 0
          Collection.bisect_left(sample, 20).should eq 1
          Collection.bisect_left(sample, 30).should eq 2
        end

        it 'returns the index when the item is not in the sample with a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          Collection.bisect_left(sample, 15){|x| x[:count]}.should eq 1
          Collection.bisect_left(sample, 25){|x| x[:count]}.should eq 2
        end

        it 'returns the index when the item is in the sample with a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          Collection.bisect_left(sample, 10){|x| x[:count]}.should eq 0
          Collection.bisect_left(sample, 20){|x| x[:count]}.should eq 1
          Collection.bisect_left(sample, 30){|x| x[:count]}.should eq 2
        end
      end

      context '#bisect_right' do

        it 'returns nil when the sample is nil' do
          Collection.bisect_right(nil, 10).should be_nil
        end

        it 'returns zero when the sample is empty' do
          Collection.bisect_right([], 10).should eq 0
        end

        it 'returns the index when the item is not in the sample' do
          sample = [10, 20, 30]
          Collection.bisect_right(sample, 15).should eq 1
          Collection.bisect_right(sample, 25).should eq 2
        end

        it 'returns the index when the item is in the sample' do
          sample = [10, 20, 30]
          Collection.bisect_right(sample, 10).should eq 1
          Collection.bisect_right(sample, 20).should eq 2
          Collection.bisect_right(sample, 30).should eq 3
        end

        it 'returns the index when the item is not in the sample with a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          Collection.bisect_right(sample, 15){|x| x[:count]}.should eq 1
          Collection.bisect_right(sample, 25){|x| x[:count]}.should eq 2
        end

        it 'returns the index when the item is in the sample with a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          Collection.bisect_right(sample, 10){|x| x[:count]}.should eq 1
          Collection.bisect_right(sample, 20){|x| x[:count]}.should eq 2
          Collection.bisect_right(sample, 30){|x| x[:count]}.should eq 3
        end
      end

      context '#insort_left!' do

        it 'returns the item in a one-element array when the sample is nil' do
          Collection.insort_left!(nil, 10).should eq [10]
        end

        it 'returns the item in a one-element array when the sample is empty' do
          sample = []
          insort = Collection.insort_left!(sample, 10)
          insort.should eq [10]
          sample.object_id.should eq insort.object_id
        end

        it 'inserts an element that is not in the sample' do
          sample = [10, 20, 30]
          insort = Collection.insort_left!(sample, 15)
          insort.should eq [10, 15, 20, 30]
          sample.object_id.should eq insort.object_id
        end

        it 'inserts an element that is in the sample' do
          item = 'b'
          sample = ['a', 'b', 'c']
          insort = Collection.insort_left!(sample, item)
          insort.should eq ['a', 'b', 'b', 'c']
          sample.object_id.should eq insort.object_id
          sample[1].object_id.should eq item.object_id
        end

        it 'inserts an element that is not in the sample using a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          insort = Collection.insort_left!(sample, {:count => 15}){|x| x[:count]}
          insort.should eq [
            {:count => 10},
            {:count => 15},
            {:count => 20},
            {:count => 30}
          ]
          sample.object_id.should eq insort.object_id
        end

        it 'inserts an element that is in the sample using a block' do
          item = {:letter => 'b'}
          sample = [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          insort = Collection.insort_left!(sample, item){|x| x[:letter]}
          insort.should eq [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          sample.object_id.should eq insort.object_id
          sample[1].object_id.should eq item.object_id
        end
      end

      context '#insort_left' do

        it 'returns the item in a one-element array when the sample is nil' do
          Collection.insort_left(nil, 10).should eq [10]
        end

        it 'returns the item in a one-element array when the sample is empty' do
          sample = []
          insort = Collection.insort_left(sample, 10)
          insort.should eq [10]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is not in the sample' do
          sample = [10, 20, 30]
          insort = Collection.insort_left(sample, 15)
          insort.should eq [10, 15, 20, 30]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is in the sample' do
          item = 'b'
          sample = ['a', 'b', 'c']
          insort = Collection.insort_left(sample, item)
          insort.should eq ['a', 'b', 'b', 'c']
          sample.object_id.should_not eq insort.object_id
          insort[1].object_id.should eq item.object_id
        end

        it 'inserts an element when the sample class does not support the #dup method' do
          sample = [10, 20, 30]
          sample.should_receive(:respond_to?).with(:dup).and_return(false)
          insort = Collection.insort_left(sample, 15)
          insort.should eq [10, 15, 20, 30]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is not in the sample using a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          insort = Collection.insort_left(sample, {:count => 15}){|x| x[:count]}
          insort.should eq [
            {:count => 10},
            {:count => 15},
            {:count => 20},
            {:count => 30}
          ]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is in the sample using a block' do
          item = {:letter => 'b'}
          sample = [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          insort = Collection.insort_left(sample, item){|x| x[:letter]}
          insort.should eq [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          sample.object_id.should_not eq insort.object_id
          insort[1].object_id.should eq item.object_id
        end
      end

      context '#insort_right!' do

        it 'returns the item in a one-element array when the sample is nil' do
          Collection.insort_right!(nil, 10).should eq [10]
        end

        it 'returns the item in a one-element array when the sample is empty' do
          sample = []
          insort = Collection.insort_right!(sample, 10)
          insort.should eq [10]
          sample.object_id.should eq insort.object_id
        end

        it 'inserts an element that is not in the sample' do
          sample = [10, 20, 30]
          insort = Collection.insort_right!(sample, 15)
          insort.should eq [10, 15, 20, 30]
          sample.object_id.should eq insort.object_id
        end

        it 'inserts an element that is in the sample' do
          item = 'b'
          sample = ['a', 'b', 'c']
          insort = Collection.insort_right!(sample, item)
          insort.should eq ['a', 'b', 'b', 'c']
          sample.object_id.should eq insort.object_id
          insort[2].object_id.should eq item.object_id
        end

        it 'inserts an element that is not in the sample using a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          insort = Collection.insort_right!(sample, {:count => 15}){|x| x[:count]}
          insort.should eq [
            {:count => 10},
            {:count => 15},
            {:count => 20},
            {:count => 30}
          ]
          sample.object_id.should eq insort.object_id
        end

        it 'inserts an element that is in the sample using a block' do
          item = {:letter => 'b'}
          sample = [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          insort = Collection.insort_right!(sample, item){|x| x[:letter]}
          insort.should eq [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          sample.object_id.should eq insort.object_id
          insort[2].object_id.should eq item.object_id
        end
      end

      context '#insort_right' do

        it 'returns the item in a one-element array when the sample is nil' do
          Collection.insort_right(nil, 10).should eq [10]
        end

        it 'returns the item in a one-element array when the sample is empty' do
          sample = []
          insort = Collection.insort_right(sample, 10)
          insort.should eq [10]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is not in the sample' do
          sample = [10, 20, 30]
          insort = Collection.insort_right(sample, 15)
          insort.should eq [10, 15, 20, 30]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is in the sample' do
          item = 'b'
          sample = ['a', 'b', 'c']
          insort = Collection.insort_right(sample, item)
          insort.should eq ['a', 'b', 'b', 'c']
          sample.object_id.should_not eq insort.object_id
          insort[2].object_id.should eq item.object_id
        end

        it 'inserts an element when the sample class does not support the #dup method' do
          sample = [10, 20, 30]
          sample.should_receive(:respond_to?).with(:dup).and_return(false)
          insort = Collection.insort_right(sample, 15)
          insort.should eq [10, 15, 20, 30]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is not in the sample using a block' do
          sample = [
            {:count => 10},
            {:count => 20},
            {:count => 30}
          ]
          insort = Collection.insort_right(sample, {:count => 15}){|x| x[:count]}
          insort.should eq [
            {:count => 10},
            {:count => 15},
            {:count => 20},
            {:count => 30}
          ]
          sample.object_id.should_not eq insort.object_id
        end

        it 'inserts an element that is in the sample using a block' do
          item = {:letter => 'b'}
          sample = [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          insort = Collection.insort_right(sample, item){|x| x[:letter]}
          insort.should eq [
            {:letter => 'a'},
            {:letter => 'b'},
            {:letter => 'b'},
            {:letter => 'c'}
          ]
          sample.object_id.should_not eq insort.object_id
          insort[2].object_id.should eq item.object_id
        end
      end
    end

    context '#collect' do

      it 'returns an empty array when given a nil sample' do
        Collection.collect(nil).should eq []
      end

      it 'returns an empty array when given an empty sample' do
        Collection.collect([].freeze).should eq []
      end

      it 'returns an array when given a valid sample' do
        sample = [1, 2, 3, 4, 5].freeze
        collected = Collection.collect(sample)
        collected.size.should eq sample.size
        collected.each {|item| sample.should include(item)}
        sample.each {|item| collected.should include(item)}
      end

      it 'returns an array when given a sample with a block' do
        sample = [
          {:count => 1},
          {:count => 2},
          {:count => 3}
        ].freeze

        collected = Collection.collect(sample){|item| item[:count]}
        collected.size.should eq sample.size
        sample.each {|item| collected.should include(item.values.first)}
      end
    end

    context '#index_and_catalog' do

      let(:sample) { [13, 18, 13, 14, 13, 16, 14, 21, 13].freeze }
      let(:expected) { [ [0, 13], [1, 18], [2, 13], [3, 14], [4, 13], [5, 16], [6, 14], [7, 21], [8, 13] ].freeze }

      it 'returns an empty catalog when given a nil sample' do
        Collection.index_and_catalog(nil).should eq []
      end

      it 'returns an empty catalog when given an empty sample' do
        Collection.index_and_catalog([].freeze).should eq []
      end

      it 'returns an catalog when given a valid sample' do
        cataloged = Collection.index_and_catalog(sample)
        cataloged.should eq expected
      end

      it 'returns an catalog when given a sample with a block' do
        sample = [
          {:count => 13}, {:count => 18}, {:count => 13},
          {:count => 14}, {:count => 13}, {:count => 16},
          {:count => 14}, {:count => 21}, {:count => 13}
        ].freeze

        cataloged = Collection.index_and_catalog(sample){|item| item[:count]}
        cataloged.should eq expected
      end
    end

    context '#catalog_hash' do

      it 'returns an empty catalog when the hash is nil' do
        Collection.catalog_hash(nil).should eq []
      end

      it 'returns an empty catalog when the hash is empty' do
        Collection.catalog_hash({}.freeze).should eq []
      end

      it 'returns a catalog when given a populated hash' do
        sample = {
          7  => 8,
          12 => 8,
          17 => 14,
          22 => 4,
          27 => 6,
          32 => 12,
          37 => 8,
          42 => 3,
          47 => 2
        }.freeze

        catalog = Collection.catalog_hash(sample)
        catalog.size.should eq sample.size

        catalog[0].should eq [7, 8]
        catalog[1].should eq [12, 8]
        catalog[2].should eq [17, 14]
        catalog[3].should eq [22, 4]
        catalog[4].should eq [27, 6]
        catalog[5].should eq [32, 12]
        catalog[6].should eq [37, 8]
        catalog[7].should eq [42, 3]
        catalog[8].should eq [47, 2]
      end

      it 'applies the supplied block to every value in the hash' do
        sample = {
          7  => {:count => 8},
          12 => {:count => 8},
          17 => {:count => 14},
          22 => {:count => 4},
          27 => {:count => 6},
          32 => {:count => 12},
          37 => {:count => 8},
          42 => {:count => 3},
          47 => {:count => 2}
        }.freeze

        catalog = Collection.catalog_hash(sample){|item| item[:count]}
        catalog.size.should eq sample.size

        catalog[0].should eq [7, 8]
        catalog[1].should eq [12, 8]
        catalog[2].should eq [17, 14]
        catalog[3].should eq [22, 4]
        catalog[4].should eq [27, 6]
        catalog[5].should eq [32, 12]
        catalog[6].should eq [37, 8]
        catalog[7].should eq [42, 3]
        catalog[8].should eq [47, 2]
      end
    end

    context '#hash_catalog' do

      it 'returns an empty hash when the catalog is nil' do
        Collection.hash_catalog(nil).should == {}
      end

      it 'returns an empty hash when the catalog is empty' do
        Collection.hash_catalog({}.freeze).should == {}
      end

      it 'returns a hash when given a catalog hash' do
        sample = [
          [7, 8],
          [12, 8],
          [17, 14],
          [22, 4],
          [27, 6],
          [32, 12],
          [37, 8],
          [42, 3],
          [47, 2]
        ].freeze

        hash = Collection.hash_catalog(sample)
        hash.size.should eq sample.size

        hash[7].should eq 8
        hash[12].should eq 8
        hash[17].should eq 14
        hash[22].should eq 4
        hash[27].should eq 6
        hash[32].should eq 12
        hash[37].should eq 8
        hash[42].should eq 3
        hash[47].should eq 2
      end

      it 'keeps the last value when duplicate keys exist' do
        sample = [
          [7, 0],
          [12, 1],
          [12, 2],
          [12, 3],
          [12, 4],
          [12, 5],
          [12, 6],
          [47, 7]
        ].freeze

        hash = Collection.hash_catalog(sample)
        hash.size.should eq 3

        hash[7].should eq 0
        hash[12].should eq 6
        hash[47].should eq 7
      end

      it 'applies the supplied block to every value in the hash' do
        sample = [
          [7, {:count => 8}],
          [12, {:count => 8}],
          [17, {:count => 14}],
          [22, {:count => 4}],
          [27, {:count => 6}],
          [32, {:count => 12}],
          [37, {:count => 8}],
          [42, {:count => 3}],
          [47, {:count => 2}]
        ].freeze

        hash = Collection.hash_catalog(sample){|item| item[:count]}
        hash.size.should eq sample.size

        hash[7].should eq 8
        hash[12].should eq 8
        hash[17].should eq 14
        hash[22].should eq 4
        hash[27].should eq 6
        hash[32].should eq 12
        hash[37].should eq 8
        hash[42].should eq 3
        hash[47].should eq 2
      end
    end

    context 'predicates' do

      context '#ascending?' do

        it 'returns false for a nil sample' do
          Collection.ascending?(nil).should be_false
        end

        it 'returns true for an empty sample' do
          Collection.ascending?([].freeze).should be_true
        end

        it 'returns true for a one-element sample' do
          Collection.ascending?([100].freeze).should be_true
        end

        it 'returns true for an ascending collection' do
          Collection.ascending?([1, 2, 3, 4].freeze).should be_true
        end

        it 'returns false for a non-ascending collection' do
          Collection.ascending?([1, 3, 2, 4].freeze).should be_false
        end

        it 'returns the correct value when given a block' do
          sample = [
            {:count => 11}, 
            {:count => 12},
            {:count => 13},
            {:count => 14}
          ].freeze

          Collection.ascending?(sample){|item| item[:count]}.should be_true
        end
      end

      context '#descending?' do

        it 'returns false for a nil sample' do
          Collection.descending?(nil).should be_false
        end

        it 'returns true for an empty sample' do
          Collection.descending?([].freeze).should be_true
        end

        it 'returns true for a one-element sample' do
          Collection.descending?([100].freeze).should be_true
        end

        it 'returns true for an descending collection' do
          Collection.descending?([4, 3, 2, 1].freeze).should be_true
        end

        it 'returns false for a non-descending collection' do
          Collection.descending?([1, 3, 2, 4].freeze).should be_false
        end

        it 'returns the correct value when given a block' do
          sample = [
            {:count => 21},
            {:count => 20},
            {:count => 19},
            {:count => 18}
          ].freeze

          Collection.descending?(sample){|item| item[:count]}.should be_true
        end
      end
    end

    context 'partitioning' do

      context '#slice' do

        context 'function signature' do

          it 'raises an exception with less than two arguments' do
            lambda {
              Functional.slice(1)
            }.should raise_exception(ArgumentError)
          end

          it 'raises and exception with more than three arguments' do
            lambda {
              Functional.slice(1, 2, 3, 4)
            }.should raise_exception(ArgumentError)
          end
        end

        context 'with index' do

          it 'returns nil if the positive index is out of range' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, 9).should be_nil
          end

          it 'returns nil if the negative index is out of range' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, -10).should be_nil
          end

          it 'returns the element at index for a non-negative index' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, 3).should eq 14
          end

          it 'returns the element counted backward from the end for a negative index' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, -4).should eq 16
          end
        end

        context 'with range' do

          it 'returns nil when the positive index is out of range' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, (9..5)).should be_nil
          end

          it 'returns nil when the index is negative' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, (-1..5)).should be_nil
          end

          it 'returns a subarray starting at start and continuing to end' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, (1..5)).should eq [13, 13, 14, 13, 16]
          end

          it 'returns a subarray to the end when the end is out of range' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, (1..100)).should eq [13, 13, 14, 13, 16, 14, 21, 13]
          end
        end

        context 'with start index and length' do

          it 'returns nil when the positive index is out of range' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, 9, 5).should be_nil
          end

          it 'returns nil when the index is negative' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, -1, 5).should be_nil
          end

          it 'returns a subarray specified by range' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, 2, 4).should eq [13, 14, 13, 16]
          end

          it 'returns a subarray to the end when length is out of range' do
            sample = [18, 13, 13, 14, 13, 16, 14, 21, 13].freeze
            Functional.slice(sample, 2, 100).should eq [13, 14, 13, 16, 14, 21, 13]
          end
        end
      end
    end
  end
end
