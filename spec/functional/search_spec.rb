require 'spec_helper'

module Functional

  describe Search do

    context '#linear_search' do

      let(:sample) do
        [3, 5, 6, 7, 8, 11, 15, 21, 22, 28, 30, 32, 33, 34, 40].freeze
      end

      it 'returns nil for a nil sample' do
        Search.linear_search(nil, 1).should be_nil
      end

      it 'returns nil for an empty sample' do
        Search.linear_search([].freeze, 1).should be_nil
      end

      it 'returns the index of the item when found' do
        index = Search.linear_search(sample, 11)
        index.should eq 5
      end

      it 'returns the index of the item when using a block' do
        sample = [
          {:count => 11}, 
          {:count => 12},
          {:count => 13},
          {:count => 14},
          {:count => 16},
          {:count => 17},
          {:count => 18},
          {:count => 19},
          {:count => 20},
          {:count => 21}
        ].freeze

        index = Search.linear_search(sample, 14){|item| item[:count]}
        index.should eq 3
      end

      it 'returns nil when not found' do
        index = Search.linear_search(sample, 13)
        index.should be_nil
      end

      it 'supports an :imin option for an alternate low index' do
        index = Search.linear_search(sample, 11, :imin => 3)
        index.should eq 5

        index = Search.linear_search(sample, 11, :imin => 10)
        index.should be_nil
      end

      it 'supports an :imax option for an alternate high index' do
        index = Search.linear_search(sample, 11, :imax => 10)
        index.should eq 5

        index = Search.linear_search(sample, 11, :imax => 4)
        index.should be_nil
      end

      it 'behaves consistently when :imin equals :imax' do
        index = Search.linear_search(sample, 3, :imin => 5, :imax => 5)
        index.should be_nil

        index = Search.linear_search(sample, 11, :imin => 5, :imax => 5)
        index.should eq 5

        index = Search.linear_search(sample, 30, :imin => 5, :imax => 5)
        index.should be_nil
      end

      it 'sets :imin to zero (0) when given a negative number' do
        index = Search.linear_search(sample, 11, :imin => -1)
        index.should eq 5
      end

      it 'sets :imax to the uppermost index when :imax is out of range' do
        index = Search.linear_search(sample, 11, :imax => 100)
        index.should eq 5
      end

      it 'returns nil when :imin is greater than :imax' do
        index = Search.linear_search(sample, 1, :imin => 10, :imax => 5)
        index.should be_nil
      end
    end

    context '#binary_search' do

      let(:sample) do
        [3, 5, 6, 7, 8, 11, 15, 21, 22, 28, 30, 32, 33, 34, 40].freeze
      end

      it 'returns nil for a nil sample' do
        Search.binary_search(nil, 1).should be_nil
      end

      it 'returns nil for an empty sample' do
        Search.binary_search([].freeze, 1).should be_nil
      end

      it 'returns the index of the item when found as [index, index]' do
        index = Search.binary_search(sample, 11)
        index.should eq [5, 5]
      end

      it 'returns the index of the item when using a block' do
        sample = [
          {:count => 11}, 
          {:count => 12},
          {:count => 13},
          {:count => 14},
          {:count => 16},
          {:count => 17},
          {:count => 18},
          {:count => 19},
          {:count => 20},
          {:count => 21}
        ].freeze

        index = Search.binary_search(sample, 14){|item| item[:count]}
        index.should eq [3, 3]
      end

      it 'returns the indexes above and below when not found - below, above' do
        index = Search.binary_search(sample, 13)
        index.should eq [5, 6]
      end

      it 'returns nil and the low index when the item is out of range on the low end - [nil, low]' do
        index = Search.binary_search(sample, 1)
        index.should eq [nil, 0]
      end

      it 'returns the high index and nil when the item is out of range on the high end - [high, nil]' do
        index = Search.binary_search(sample, 41)
        index.should eq [14, nil]
      end

      it 'supports an :imin option for an alternate low index' do
        index = Search.binary_search(sample, 11, :imin => 3)
        index.should eq [5, 5]

        index = Search.binary_search(sample, 11, :imin => 10)
        index.should eq [nil, 10]
      end

      it 'supports an :imax option for an alternate high index' do
        index = Search.binary_search(sample, 11, :imax => 10)
        index.should eq [5, 5]

        index = Search.binary_search(sample, 11, :imax => 4)
        index.should eq [4, nil]
      end

      it 'behaves consistently when :imin equals :imax' do
        index = Search.binary_search(sample, 3, :imin => 5, :imax => 5)
        index.should eq [nil, 5]

        index = Search.binary_search(sample, 11, :imin => 5, :imax => 5)
        index.should eq [5, 5]

        index = Search.binary_search(sample, 30, :imin => 5, :imax => 5)
        index.should eq [5, nil]
      end

      it 'sets :imin to zero (0) when given a negative number' do
        index = Search.binary_search(sample, 1, :imin => -1)
        index.should eq [nil, 0]
      end

      it 'sets :imax to the uppermost index when :imax is out of range' do
        index = Search.binary_search(sample, 41, :imax => 100)
        index.should eq [14, nil]
      end

      it 'returns nil when :imin is greater than :imax' do
        index = Search.binary_search(sample, 1, :imin => 10, :imax => 5)
        index.should be_nil
      end
    end
  end
end
