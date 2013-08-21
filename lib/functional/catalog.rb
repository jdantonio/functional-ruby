module Functional

  # A collection of key/value pairs similar to a hash but ordered.
  # Access is via index (like an array) rather than by key (like a
  # hash). Supports duplicate keys. Indexing starts at zero.
  class Catalog
    include Enumerable

    # Create a new Catalog from the given data. When +data+ is nil
    # or an empty collection the resulting Catalog will be empty.
    # When +data+ is an array, hash, or catalog array the appropriate
    # +#from_+ factory method will be called. The +:from+ option is
    # used to indicate the type of the source data.
    #
    # If a block is given each value in the from the source array will
    # be passed to the block and the result will be stored as the value
    # in the Catalog.
    #
    # @param [Array, Hash, Catalog] data the data to construct the
    #   Catalog from
    # @param [Hash] opts processing options
    #
    # @option opts [Symbol] :from the type of the data source. Valid values
    #   are :catalog/:catalogue, :hash, :array (default :catalog).
    def initialize(data=nil, opts={})

      if block_given?

        @data = []
        data.each do |item|
          @data << yield(item)
        end

      else
        from = opts[:from]
        from = :array if [:set, :list, :stack, :queue, :vector].include?(from)
        from = "from_#{from}".to_sym

        if Catalog.respond_to?(from)
          @data = Catalog.send(from, data)
          @data = @data.instance_variable_get(:@data)
        elsif opts[:from].nil? && !data.nil?
          @data = Catalog.from_catalog(data)
          @data = @data.instance_variable_get(:@data)
        else
          @data = []
        end
      end
    end

    # Creates a new Catalog object from a hash. Each key/value pair in the
    # hash will be converted to a key/value array in the new Catalog. If a
    # block is given each value in the array will be passed to the block
    # and the result will be stored as the value in the Catalog.
    def self.from_hash(data = {})
      collected = []
      data.each do |key, value|
        value = yield(value) if block_given?
        collected << [key, value]
      end
      catalog = Catalog.new
      catalog.instance_variable_set(:@data, collected)
      return catalog
    end

    # Creates a new catalog object from an array. Each successive pair of
    # elements will become a key/value pair in the new Catalog. If the source
    # array has an odd number of elements the last element will be discarded.
    # If a block is given each element in the source array will be passed to
    # the block and the result will be stored in the new Catalog.
    def self.from_array(*args)
      collected = []
      data = args.flatten

      max = ((data.size % 2 == 0) ? data.size-1 : data.size-2)
      (0..max).step(2) do |index|
        key = block_given? ? yield(data[index]) : data[index]
        value = block_given? ? yield(data[index+1]) : data[index+1]
        collected << [key, value]
      end

      catalog = Catalog.new
      catalog.instance_variable_set(:@data, collected)
      return catalog
    end

    # Creates a new Catalog object from an array of key/value pairs.
    # Each key/value pair in the source array will be stored in the new
    # Catalog. If a block is given each value in the from the source array
    # will be passed to the block and the result will be stored as the
    # value in the Catalog.
    def self.from_catalog(data, *args)
      collected = []

      if args.empty? && data.size == 2 && !data.first.is_a?(Array)
        # Catalog.from_catalog([:one, 1])
        data = [data]
      elsif !args.empty?
        #Catalog.from_catalog([:one, 1], [:two, 2], [:three, 3])
        data = [data] + args
      end

      data.each do |item|
        if block_given?
          collected << [item.first, yield(item.last)]
        else
          collected << item
        end
      end
      
      catalog = Catalog.new
      catalog.instance_variable_set(:@data, collected)
      return catalog
    end

    class << self
      alias :from_catalogue :from_catalog
    end

    # Returns true if self array contains no elements.
    def empty?
      size == 0
    end

    # Returns the number of elements in self. May be zero.
    def length
      @data.length
    end

    alias :size :length

    # Returns the first element, or the first n elements, of the array.
    # If the array is empty, the first form returns nil, and the second
    # form returns an empty array.
    def first
      @data.first
    end

    # Returns the last element(s) of self. If the array is empty,
    # the first form returns nil.
    def last
      @data.last
    end

    # Equality—Two arrays are equal if they contain the same number of
    # elements and if each element is equal to (according to Object.==)
    # the corresponding element in the other array.
    def ==(other)
      if other.is_a? Catalog
        return (@data == other.instance_variable_get(:@data))
      elsif other.is_a? Array
        return (@data == other)
      else
        return false
      end
    end

    alias :eql? :==

    # Comparison—Returns an integer (-1, 0, or +1) if this array is less
    # than, equal to, or greater than other_ary. Each object in each
    # array is compared (using <=>). If any value isn’t equal, then that
    # inequality is the return value. If all the values found are equal,
    # then the return is based on a comparison of the array lengths. Thus,
    # two arrays are “equal” according to Array#<=> if and only if they have
    # the same length and the value of each element is equal to the value of
    # the corresponding element in the other array.
    def <=>(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return @data <=> other
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :compare :<=>
    alias :compare_to :<=>

    # Returns a new array populated with the given objects.
    def [](index)
      datum = @data[index]
      return (datum.nil? ? nil : datum.dup)
    end

    alias :at :[]

    # Element Assignment—Sets the element at index, or replaces a subarray starting
    # at start and continuing for length elements, or replaces a subarray specified
    # by range. If indices are greater than the current capacity of the array, the
    # array grows automatically. A negative indices will count backward from the end
    # of the array. Inserts elements if length is zero. An IndexError is raised if a
    # negative index points past the beginning of the array. See also Array#push,
    # and Array#unshift.
    def []=(index, value)
      if (index >= 0 && index >= @data.size) || (index < 0 && index.abs > @data.size)
        raise ArgumentError.new('index must reference an existing element')
      elsif value.is_a?(Hash) && value.size == 1
        @data[index] = [value.keys.first, value.values.first]
      elsif value.is_a?(Array) && value.size == 2
        @data[index] = value.dup
      else
        raise ArgumentError.new('value must be a one-element hash or a two-element array')
      end
    end

    # Returns a string representation of Catalog.
    def to_s
      return @data.to_s
    end

    # Set Intersection—Returns a new array containing elements common to the two
    # arrays, with no duplicates.
    def &(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data & other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :intersection :&

    # Concatenation—Returns a new array built by concatenating the two arrays
      # together to produce a third array.
    def +(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data + other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :add :+
    alias :sum :+

    # Set Union—Returns a new array by joining this array with other_array,
    # removing duplicates.
    def |(other)
      other = other.instance_variable_get(:@data) if other.is_a?(Catalog)
      if other.is_a? Array
        return Catalog.from_catalog(@data | other)
      else
        raise TypeError.new("can't convert #{other.class} into Catalog")
      end
    end

    alias :union :|

    # Append—Pushes the given object(s) on to the end of this array.
    # This expression returns the array itself, so several appends
    # may be chained together.
    def push(item)
      if item.is_a?(Hash) && item.size == 1
        @data << [item.keys.first, item.values.first]
        return self
      elsif item.is_a?(Array) && item.size == 2
        @data << item
        return self
      else
        raise TypeError.new("can't convert #{item.class} into Catalog")
      end
    end

    alias :<< :push
    alias :append :push

    # Removes the last element from self and returns it, or nil if the
    # Catalog is empty.
    def pop
      if self.empty?
        return nil
      else
        return @data.pop
      end
    end

    # Copies the last element from self and returns it, or nil if the
    # Catalog is empty.
    def peek
      if self.empty?
        return nil
      else
        return @data.last.dup
      end
    end

    # Returns a new array populated with the keys from this hash.
    # See also Hash#values.
    def keys
      return @data.collect{|item| item.first}
    end

    # Returns a new array populated with the values from hsh.
    # See also Hash#keys.
    def values
      return @data.collect{|item| item.last}
    end

    # Calls block once for each key in hsh, passing the key and value
    # to the block as a two-element array. Because of the assignment
    # semantics of block parameters, these elements will be split out
    # if the block has two formal parameters. Also see Hash.each_pair,
    # which will be marginally more efficient for blocks with two
    # parameters.
    def each(&block)
      @data.each do |item|
        yield(item)
      end
    end

    # Calls block once for each key in hsh, passing the key and value as parameters.
    def each_pair(&block)
      @data.each do |item|
        yield(item.first, item.last)
      end
    end

    # Calls block once for each key in hsh, passing the key as a parameter.
    def each_key(&block)
      @data.each do |item|
        yield(item.first)
      end
    end

    # Calls block once for each key in hsh, passing the value as a parameter.
    def each_value(&block)
      @data.each do |item|
        yield(item.last)
      end
    end

    # Returns true if the given object is present in self (that is,
    # if any object == anObject), false otherwise.
    def include?(key=nil, value=nil)
      if key && value
        return @data.include?([key, value])
      elsif key.is_a?(Array)
        return @data.include?(key)
      elsif key.is_a?(Hash) && key.size == 1
        return @data.include?([key.keys.first, key.values.first])
      else
        return false
      end
    end

    # Element Reference—Returns the element at index, or returns a
    # subarray starting at start and continuing for length elements,
    # or returns a subarray specified by range. Negative indices count
    # backward from the end of the array (-1 is the last element).
    # Returns nil if the index (or starting index) are out of range.
    def slice(index, length=nil)
      if length.nil?
        catalog = @data.slice(index)
      else
        catalog = @data.slice(index, length)
      end
      return Catalog.new(catalog)
    end

    # Deletes the element(s) given by an index (optionally with a length)
    # or by a range. Returns the deleted object, subarray, or nil if the
    # index is out of range.
    def slice!(index, length=nil)
      if length.nil?
        catalog = @data.slice!(index)
      else
        catalog = @data.slice!(index, length)
      end
      return Catalog.new(catalog)
    end

    # Return a new Catalog created by sorting self according to the natural
    # sort order of the keys.
    def sort_by_key
      sorted = @data.sort{|a, b| a.first <=> b.first}
      return Catalog.new(sorted)
    end

    # Sort self according to the natural sort order of the keys. Returns self.
    def sort_by_key!
      sorted = @data.sort!{|a, b| a.first <=> b.first}
      return self
    end

    # Return a new Catalog created by sorting self according to the natural
    # sort order of the values.
    def sort_by_value
      sorted = @data.sort{|a, b| a.last <=> b.last}
      return Catalog.new(sorted)
    end

    # Sort self according to the natural sort order of the values. Returns self.
    def sort_by_value!
      sorted = @data.sort!{|a, b| a.last <=> b.last}
      return self
    end

    # Returns a new array created by sorting self. Comparisons for
    # the sort will be done using the <=> operator or using an
    # optional code block. The block implements a comparison between
    # a and b, returning -1, 0, or +1. See also Enumerable#sort_by.
    def sort(&block)
      sorted = @data.sort(&block)
      return Catalog.new(sorted)
    end

    # Sorts self. Comparisons for the sort will be done using the <=>
    # operator or using an optional code block. The block implements a
    # comparison between a and b, returning -1, 0, or +1.
    # See also Enumerable#sort_by.
    def sort!(&block)
      sorted = @data.sort!(&block)
      return self
    end

    # Returns a new array that is a one-dimensional flattening of self.
    def to_a
      return @data.flatten
    end

    # Returns a new hash by converting each key/value pair in self into
    # a key/value pair in the hash. When duplicate keys are encountered
    # the last value associated with that key is kept and the others are
    # discarded.
    def to_hash
      catalog = {}
      @data.each do |item|
        catalog[item.first] = item.last
      end
      return catalog
    end

    # Returns a new array that is the dat equivalent of self where each
    # key/value pair is an two-element array within the returned array.
    def to_catalog
      return @data.dup
    end

    alias :to_catalogue :to_catalog

    # Deletes items from self that are equal to obj. If the item is
    # not found, returns nil. If the optional code block is given,
    # returns the result of block if the item is not found.
    def delete(key, value=nil)
      item = nil

      if key && value
        item = @data.delete([key, value])
      elsif key.is_a? Array
        item = @data.delete(key)
      elsif key.is_a? Hash
        item = @data.delete([key.keys.first, key.values.first])
      end

      item = yield if item.nil? && block_given?
      return item
    end

    # Deletes the element at the specified index, returning that element,
    # or nil if the index is out of range. See also Array#slice!.
    def delete_at(index)
      item = @data.delete_at(index)
      item = yield if item.nil? && block_given?
      return item
    end

    # Deletes every element of self for which block evaluates to true.
    def delete_if(&block)
      raise ArgumentError.new('no block supplied') unless block_given?
      if block.arity <= 1
        items = @data.delete_if(&block)
      else
        items = []
        @data.each do |key, value|
          items << [key, value] if yield(key, value)
        end
        items.each {|item| @data.delete(item)}
      end
      return self
    end
  end

  class Catalogue < Catalog; end
end
