module Functional

  module Collection
    extend self

    # Returns a random sample of #size integers between 0 and 100 or
    # the provided :min and/or :max options.
    #
    # @param [Integer] size the size of the sample to create
    # @param [Hash] opts processing options
    #
    # @option opts [Integer] :min the minimum value in the sample
    # @option opts [Integer] :max the maximun value in the sample
    #
    # @return [Array] an array of integers
    def random_sample(size, opts={})
      min = opts[:min].to_i
      max = opts[:max] || 100
      sample = []
      size.times do
        sample << rand(max-min) + min
      end
      return sample
    end

    # Return the index where to insert item x in list a, assuming a is sorted.
    #
    # The return value i is such that all e in a[:i] have e < x, and all e in
    # a[i:] have e >= x.  So if x already appears in the list, a.insert(x) will
    # insert just before the leftmost x already there.
    #
    # Optional args lo (default 0) and hi (default len(a)) bound the
    # slice of a to be searched.
    #
    # @see http://docs.python.org/3/library/bisect.html
    # @see http://hg.python.org/cpython/file/3.3/Lib/bisect.py
    # @see http://effbot.org/librarybook/bisect.htm
    def bisect_left(a, x, opts={})
      return nil if a.nil?
      return 0 if a.empty?

      lo = (opts[:lo] || opts[:low]).to_i
      hi = opts[:hi] || opts[:high] || a.length

      while lo < hi
        mid = (lo + hi) / 2
        v = (block_given? ? yield(a[mid]) : a[mid])
        if v < x
          lo = mid + 1
        else
          hi = mid
        end
      end
      return lo
    end

    # Return the index where to insert item x in list a, assuming a is sorted.
    #
    # The return value i is such that all e in a[:i] have e <= x, and all e in
    # a[i:] have e > x.  So if x already appears in the list, a.insert(x) will
    # insert just after the rightmost x already there.
    #
    # Optional args lo (default 0) and hi (default len(a)) bound the
    # slice of a to be searched.
    #
    # @see http://docs.python.org/3/library/bisect.html
    # @see http://hg.python.org/cpython/file/3.3/Lib/bisect.py
    # @see http://effbot.org/librarybook/bisect.htm
    def bisect_right(a, x, opts={})
      return nil if a.nil?
      return 0 if a.empty?

      lo = (opts[:lo] || opts[:low]).to_i
      hi = opts[:hi] || opts[:high] || a.length

      while lo < hi
        mid = (lo + hi) / 2
        v = (block_given? ? yield(a[mid]) : a[mid])
        if x < v
          hi = mid
        else
          lo = mid + 1
        end
      end
      return lo
    end

    alias_method :bisect, :bisect_right

    # Insert item x in list a, and keep it sorted assuming a is sorted.
    #
    # If x is already in a, insert it to the left of the leftmost x.
    #
    # Optional args lo (default 0) and hi (default len(a)) bound the
    # slice of a to be searched.
    #
    # @see http://docs.python.org/3/library/bisect.html
    # @see http://hg.python.org/cpython/file/3.3/Lib/bisect.py
    # @see http://effbot.org/librarybook/bisect.htm
    def insort_left(a, x, opts={}, &block)
      return [x] if a.nil?
      if a.respond_to?(:dup)
        a = a.dup
      else
        a = collect(a)
      end
      return insort_left!(a, x, opts, &block)
    end

    # Insert item x in list a, and keep it sorted assuming a is sorted.
    # Returns a duplicate of the original list, leaving it intact.
    #
    # If x is already in a, insert it to the left of the leftmost x.
    #
    # Optional args lo (default 0) and hi (default len(a)) bound the
    # slice of a to be searched.
    #
    # @see http://docs.python.org/3/library/bisect.html
    # @see http://hg.python.org/cpython/file/3.3/Lib/bisect.py
    # @see http://effbot.org/librarybook/bisect.htm
    def insort_left!(a, x, opts={}, &block)
      return [x] if a.nil?
      return a << x if a.empty?

      v = (block_given? ? yield(x) : x)
      index = bisect_left(a, v, opts, &block)
      return a.insert(index, x)
    end

    # Insert item x in list a, and keep it sorted assuming a is sorted.
    # Returns a duplicate of the original list, leaving it intact.
    #
    # If x is already in a, insert it to the right of the rightmost x.
    #
    # Optional args lo (default 0) and hi (default len(a)) bound the
    # slice of a to be searched.
    #
    # @see http://docs.python.org/3/library/bisect.html
    # @see http://hg.python.org/cpython/file/3.3/Lib/bisect.py
    # @see http://effbot.org/librarybook/bisect.htm
    def insort_right(a, x, opts={}, &block)
      return [x] if a.nil?
      if a.respond_to?(:dup)
        a = a.dup
      else
        a = collect(a)
      end
      return insort_right!(a, x, opts, &block)
    end

    alias_method :insort, :insort_right

    # Insert item x in list a, and keep it sorted assuming a is sorted.
    #
    # If x is already in a, insert it to the right of the rightmost x.
    #
    # Optional args lo (default 0) and hi (default len(a)) bound the
    # slice of a to be searched.
    #
    # @see http://docs.python.org/3/library/bisect.html
    # @see http://hg.python.org/cpython/file/3.3/Lib/bisect.py
    # @see http://effbot.org/librarybook/bisect.htm
    def insort_right!(a, x, opts={}, &block)
      return [x] if a.nil?
      return a << x if a.empty?

      v = (block_given? ? yield(x) : x)
      index = bisect_right(a, v, opts, &block)
      return a.insert(index, x)
    end

    alias_method :insort!, :insort_right!

    # Collect sample data from a generic collection, processing each item
    # with a block when given. Returns an array of the items from +data+
    # in order.
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to be collected
    #
    # @return [Array] an array of zero or more items
    def collect(data, opts={})
      return [] if data.nil?
      sample = []
      data.each do |datum|
        datum = yield(datum) if block_given?
        sample << datum
      end
      return sample
    end

    # Collect sample data from a generic collection, processing each item
    # with a block when given. Returns an array of arrays. Each element
    # is a two-element array where the first element is the index within
    # the outer array and the second element is the corresponding item
    # from within +data+. The elements in the returned array are in the
    # same order as the original +data+ collection.
    #
    # @example
    #   sample = [5, 1, 9, 3, 14, 9, 7]
    #   Collection.catalog(sample) #=> [[0, 5], [1, 1], [2, 9], [3, 3], [4, 14], [5, 9], [6, 7]]
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to be collected
    #
    # @return [Array] an array of zero or more items
    def index_and_catalog(data, opts={})
      return [] if data.nil?
      sample = []
      index = 0
      data.each do |datum|
        datum = yield(datum) if block_given?
        sample << [index, datum]
        index += 1
      end
      return sample
    end

    alias_method :index_and_catalogue, :index_and_catalog

    # Convert a hash to catalog.
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to convert
    # @param [Hash] opts search options
    #
    # @return [Array] if the data set is in ascending order
    def catalog_hash(data, opts={})
      return [] if data.nil? || data.empty?
      catalog = []
      data.each do |key, value|
        value = yield(value) if block_given?
        catalog << [key, value]
      end
      return catalog
    end

    alias_method :catalogue_hash, :catalog_hash

    # Convert a catalog to a hash. Keeps the last value when keys are
    # duplicated.
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data to convert
    # @param [Hash] opts search options
    #
    # @return [Hash] if the data set is in ascending order
    def hash_catalog(data, opts={})
      return {} if data.nil? || data.empty?
      hash = {}
      data.each do |item|
        value = (block_given? ? yield(item.last) : item.last)
        hash[item.first] = value
      end
      return hash
    end

    alias_method :hash_catalogue, :hash_catalog

    # Helper function for determine if the elements in a collection
    # are in monotonical order.
    #
    # @param [Enumerable] data the data to convert
    #
    # @return [Lambda] a Lambda to determine if the elements in a collection
    # are in monotonical order the user set
    def in_order?(compare_fn)
      -> col, &blk do
        if blk
          col.map {|e| blk[e] }
             .each_cons(2)
             .all? { |e1, e2| e1.send(compare_fn, e2) }
        else
          col.each_cons(2).all? { |e1, e2| e1.send(compare_fn, e2) }
        end
      end
    end

    # Scan a collection and determine if the elements are all in
    # monotonical ascending order. Returns true for an empty set and false for
    # a nil sample.
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @example
    #
    #   ascending? [1,2,2,3] ==> false
    #   ascending? ["z", "mn", "abc"] ==> false
    #   ascending? ["z", "mn", "abc"], &:length ==> true
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    #
    # @return [true, false] if the data set is in ascending order
    def ascending?(data, &blk)
      return false if data.nil?
      in_order?(:<)[data, &blk]
    end

    # Scan a collection and determine if the elements are all in
    # monotonical descending order. Returns true for an empty set and false for
    # a nil sample.
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @example
    #
    #    descending? [4, 3, 2, 1]  ==> true
    #    descending? [4, 3, 3, 2] ==> false
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    #
    # @return [true, false] if the data set is in ascending order
    def descending?(data, &blk)
      return false if data.nil?
      in_order?(:>)[data, &blk]
    end

    # Scan a collection and determine if the elements are all in
    # monotonical non-ascending order. Returns true for an empty set and false for
    # a nil sample.
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @example
    #
    #   non_ascending? [4, 3, 3, 2]  ==> true
    #   non_ascending? [4, 3, 3, 2]  ==> true
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    #
    # @return [true, false] if the data set is in ascending order
    def non_ascending?(data, &blk)
      return false if data.nil?
      in_order?(:>=)[data, &blk]
    end

    # Scan a collection and determine if the elements are all in
    # monotonical non-descending order. Returns true for an empty set and false for
    # a nil sample.
    #
    # When a block is given the block will be applied to both arguments.
    # Using a block in this way allows computation against a specific field
    # in a data set of hashes or objects.
    #
    # @example
    #
    #   non_descending? [1,2,2,3] ==> true
    #
    # @yield iterates over each element in the data set
    # @yieldparam item each element in the data set
    #
    # @param [Enumerable] data the data set to search
    #
    # @return [true, false] if the data set is in ascending order
    def non_descending?(data, &blk)
      return false if data.nil?
      in_order?(:<=)[data, &blk]
    end

    # Override of #slice from Ruby Array. Provides a consistent interface
    # to slice data structures that do not have a native #slice method.
    #
    # Returns the element at index, or returns a subarray starting at
    # start and continuing for length elements, or returns a subarray
    # specified by range. Negative indices count backward from the end
    # of the array (-1 is the last element). Returns nil if the index
    # (or starting index) is out of range.
    #
    # @overload slice(data, index)
    #   @param [Enumerable] data the collection to slice
    #   @param [Integer] index the index to slice
    #
    # @overload slice(data, start, length)
    #   @param [Enumerable] data the collection to slice
    #   @param [Integer] start the start index for the slice
    #   @param [Integer] length the length of the slice
    #
    # @overload slice(data, range)
    #   @param [Enumerable] data the collection to slice
    #   @param [Range] range range of indices to include in the slice
    #
    # @return [Array] the slice
    def slice(data, *args)
      index = args[0]
      length = args[1]
      if args.size == 1
        if index.is_a? Range
          slice_with_range(data, index)
        else
          slice_with_index(data, index)
        end
      elsif args.size == 2
        slice_with_length(data, index, length)
      else
        raise ArgumentError.new("wrong number of arguments (#{args.size} for 2..3)")
      end
    end

    # :nodoc:
    # @private
    def slice_with_index(data, index)
      return data[index]
    end

    # :nodoc:
    # @private
    def slice_with_length(data, start, length)
      range = Range.new(start, start+length-1)
      slice_with_range(data, range)
    end

    # :nodoc:
    # @private
    def slice_with_range(data, range)
      return nil if range.first < 0 || range.first >= data.size
      last = [range.last, data.size-1].min
      range = Range.new(range.first, last)
      slice = []
      range.each do |index|
        slice << data[index]
      end
      return slice
    end
  end
end
