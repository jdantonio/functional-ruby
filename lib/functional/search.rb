module Functional

  module Search
    extend self

    # Conduct a linear search against an unsorted collection and
    # return the index where the item was found. Returns nil if
    # the item is not found.
    #
    # The default behavior is to search the entire collections. The
    # options hash can be used to provide optional low and high indexes
    # (:imin and :imax). If either :imin or :imax is out of range the
    # natural collection boundary will be used.
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
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [Integer] :imin minimum index to search
    # @option opts [Integer] :imax maximum index to search
    #
    # @return [Array] the index where the item is found or nil when the
    #   collection is empty or nil
    def linear_search(data, key, opts={}, &block)

      imin, imax = check_search_options(data, key, opts, &block)
      return nil if imin.nil? || imax.nil?
      return imin if imin == imax

      index = nil
      (imin..imax).each do |i|
        if (block_given? && yield(data[i]) == key) || data[i] == key
          index = i
          break
        end
      end

      return index
    end

    # Conduct a binary search against the sorted collection and return
    # a pair of indexes indicating the result of the search. The
    # indexes will be returned as a two-element array.
    #
    # The default behavior is to search the entire collections. The
    # options hash can be used to provide optional low and high indexes
    # (:imin and :imax). If either :imin or :imax is out of range the
    # natural collection boundary will be used.
    # 
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # When the key is found both returned indexes will be the index of
    # the item. When the key is not found but the value is within the
    # range of value in the data set the returned indexes will be
    # immediately above and below where the key would reside. When
    # the key is below the lowest value in the search range the result
    # will be nil and the lowest index. When the key is higher than the
    # highest value in the search range the result will be the highest
    # index and nil. 
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    # @param [Hash] opts search options
    # @param [Block] block optional block for per-item processing
    #
    # @option opts [Integer] :imin minimum index to search
    # @option opts [Integer] :imax maximum index to search
    #
    # @return [Array] pair of indexes (see above) or nil when the collection
    #   is empty or nil
    def binary_search(data, key, opts={}, &block)

      imin, imax = check_search_options(data, key, opts, &block)
      return nil if imin.nil? && imax.nil?
      return [imin, imax] if imin == imax || imin.nil? || imax.nil?

      while (imax >= imin)
        imid = (imin + imax) / 2
        current = data[imid]
        current = yield(current) if block_given?
        if current < key
          imin = imid + 1
        elsif current > key
          imax = imid - 1
        else
          imin = imax = imid
          break
        end
      end

      return imax, imin
    end

    alias_method :bsearch, :binary_search
    alias_method :half_interval_search, :binary_search

    private

    # :nodoc:
    # @private
    def check_search_options(data, key, opts={})
      return [nil, nil] if data.nil? || data.empty?

      imin = [opts[:imin].to_i, 0].max
      imax = opts[:imax].nil? ? data.size-1 : [opts[:imax], data.size-1].min
      return [nil, nil] if imin > imax

      if block_given?
        min, max = yield(data[imin]), yield(data[imax])
      else
        min, max = data[imin], data[imax]
      end
      return [nil, imin] if key < min
      return [imin, imin] if key == min
      return [imax, nil] if key > max
      return [imax, imax] if key == max

      return [imin, imax]
    end
  end
end
