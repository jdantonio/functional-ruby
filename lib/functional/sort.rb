module Functional

  module Sort
    extend self

    # Sorts the collection using the insertion sort algorithm.
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    # @param [Hash] opts search options
    #
    # @return [Array] the sorted collection
    def insertion_sort!(data, opts={})
      return data if data.nil? || data.size <= 1

      (1..(data.size-1)).each do |j|

        key = block_given? ? yield(data[j]) : data[j]
        value = data[j]
        i = j - 1
        current = block_given? ? yield(data[i]) : data[i]

        while i >= 0 && current > key
          data[i+1] = data[i]
          i = i - 1
          current = block_given? ? yield(data[i]) : data[i]
        end

        data[i+1] = value
      end

      return data
    end
  end
end
