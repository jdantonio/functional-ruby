require 'spec_helper'

module Functional

  describe Sort do

    context '#insertion_sort!' do

      it 'returns nil for a nil sample' do
        Sort.insertion_sort!(nil).should be_nil
      end

      it 'returns the sample when the sample is empty' do
        Sort.insertion_sort!([]).should be_empty
      end

      it 'returns the sample when the sample has one element' do
        Sort.insertion_sort!([100]).should eq [100]
      end

      it 'sorts an unsorted collection' do
        sample = [31, 37, 26, 30, 2, 30, 1, 33, 5, 14, 11, 13, 17, 35, 4]
        count = sample.count
        sorted = Sort.insertion_sort!(sample)
        Functional.non_descending?(sorted).should be_true
        sorted.count.should eq count
      end

      it 'does not modify an unsorted collection' do
        sample = [1, 2, 4, 5, 11, 13, 14, 17, 26, 30, 30, 31, 33, 35, 37]
        control = sample.dup
        sorted = Sort.insertion_sort!(sample)
        sorted.should eq control
      end

      it 'it sorts a collection with a block' do
        sample = [
          {:count => 31},
          {:count => 37},
          {:count => 26},
          {:count => 30},
          {:count => 2},
          {:count => 30},
          {:count => 1}
        ]

        count = sample.count
        sorted = Sort.insertion_sort!(sample){|item| item[:count]}
        Functional.non_descending?(sorted){|item| item[:count]}.should be_true
        sorted.count.should eq count
      end

      it 'performs the sort in place' do
        lambda {
          sample = [31, 37, 26, 30, 2, 30, 1, 33, 5, 14, 11, 13, 17, 35, 4].freeze
          Sort.insertion_sort!(sample)
        }.should raise_error
      end
    end
  end
end
