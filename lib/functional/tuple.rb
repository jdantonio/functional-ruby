module Functional

  # A tuple is a pure functional data strcture that is similar to an array but is
  # immutable and of fixed length. Tuples support many of the same operations as
  # array/list/vector.
  #
  # @note The current implementation uses simple Ruby arrays. This is likely to be
  #   very inefficient for all but the smallest tuples. The more items the tuple
  #   contains, the less efficient it will become. A future version will use a fast,
  #   immutable, persistent data structure such as a finger tree or a trie.
  #
  # @since 1.1.0
  # 
  # @see http://en.wikipedia.org/wiki/Tuple
  # @see http://msdn.microsoft.com/en-us/library/system.tuple.aspx
  # @see http://www.tutorialspoint.com/python/python_tuples.htm
  # @see http://en.cppreference.com/w/cpp/utility/tuple
  # @see http://docs.oracle.com/javaee/6/api/javax/persistence/Tuple.html
  # @see http://www.erlang.org/doc/reference_manual/data_types.html
  # @see http://www.erlang.org/doc/man/erlang.html#make_tuple-2
  # @see http://en.wikibooks.org/wiki/Haskell/Lists_and_tuples#Tuples
  #
  # @!macro thread_safe_immutable_object
  class Tuple

    # Create a new tuple with the given data items in the given order.
    #
    # @param [Array] data the data items to insert into the new tuple
    # @raise [ArgumentError] if data is not an array or does not implement `to_a`
    def initialize(data = [])
      raise ArgumentError.new('data is not an array') unless data.respond_to?(:to_a)
      @data = data.to_a.dup.freeze
      self.freeze
    end

    # Retrieve the item at the given index. Indices begin at zero and increment
    # up, just like Ruby arrays. Negative indicies begin at -1, which represents the
    # last item in the tuple, and decrement toward the first item. If the
    # given index is out of range then `nil` is returned.
    #
    # @param [Fixnum] index the index of the item to be retrieved
    # @return [Object] the item at the given index or nil when index is out of bounds
    def at(index)
      @data[index]
    end
    alias_method :nth, :at
    alias_method :[], :at

    # Retrieve the item at the given index or return the given default value if the
    # index is out of bounds. The behavior of indicies follows the rules for the
    # `at` method.
    #
    # @param [Fixnum] index the index of the item to be retrieved
    # @param [Object] default the value to return when given an out of bounds index
    # @return [Object] the item at the given index or default when index is out of bounds
    #
    # @see Functional::Tuple#at
    def fetch(index, default)
      if index >= length || -index > length
        default
      else
        at(index)
      end
    end

    # The number of items in the tuple.
    #
    # @return [Fixnum] the number of items in the tuple
    def length
      @data.length
    end
    alias_method :size, :length

    # Returns a new tuple containing elements common to the two tuples, excluding any
    # duplicates. The order is preserved from the original tuple.
    #
    # @!macro [attach] tuple_method_param_other_return_tuple
    #   @param [Array] other the tuple or array-like object (responds to `to_a`) to operate on
    #   @return [Functional::Tuple] a new tuple with the appropriate items
    def intersect(other)
      Tuple.new(@data & other.to_a)
    end
    alias_method :&, :intersect

    # Returns a new tuple by joining self with other, excluding any duplicates and
    # preserving the order from the original tuple.
    #
    # @!macro tuple_method_param_other_return_tuple
    def union(other)
      Tuple.new(@data | other.to_a)
    end
    alias_method :|, :union

    # Returns a new tuple built by concatenating the two tuples
    # together to produce a third tuple.
    #
    # @!macro tuple_method_param_other_return_tuple
    def concat(other)
      Tuple.new(@data + other.to_a)
    end
    alias_method :+, :concat

    # Returns a new tuple that is a copy of the original tuple, removing any items that
    # also appear in other. The order is preserved from the original tuple.
    #
    # @!macro tuple_method_param_other_return_tuple
    def diff(other)
      Tuple.new(@data - other.to_a)
    end
    alias_method :-, :diff

    # Returns a new tuple built by concatenating the given number of copies of self.
    # Returns an empty tuple when the multiple is zero.
    #
    # @param [Fixnum] multiple the number of times to concatenate self
    # @return [Functional::Tuple] a new tuple with the appropriate items
    # @raise [ArgumentError] when multiple is a negative number
    def repeat(multiple)
      multiple = multiple.to_i
      raise ArgumentError.new('negative argument') if multiple < 0
      Tuple.new(@data * multiple)
    end
    alias_method :*, :repeat

    # Returns a new tuple by removing duplicate values in self.
    # 
    # @return [Functional::Tuple] the new tuple with only unique items
    def uniq
      Tuple.new(@data.uniq)
    end

    # Calls the given block once for each element in self, passing that element as a parameter.
    # An Enumerator is returned if no block is given.
    #
    # @yieldparam [Object] item the current item
    # @return [Enumerable] when no block is given
    def each
      return enum_for(:each) unless block_given?
      @data.each do |item|
        yield(item)
      end
    end

    # Calls the given block once for each element in self, passing that element
    # and the current index as parameters. An Enumerator is returned if no block is given.
    #
    # @yieldparam [Object] item the current item
    # @yieldparam [Fixnum] index the index of the current item
    # @return [Enumerable] when no block is given
    def each_with_index
      return enum_for(:each_with_index) unless block_given?
      @data.each_with_index do |item, index|
        yield(item, index)
      end
    end

    # Calls the given block once for each element in self, passing that element
    # and a tuple with all the remaining items in the tuple. When the last item
    # is reached ab empty tuple is passed as the second parameter. This is the
    # classic functional programming `head|tail` list processing idiom.
    # An Enumerator is returned if no block is given.
    #
    # @yieldparam [Object] head the current item for this iteration
    # @yieldparam [Tuple] tail the remaining items (tail) or an empty tuple when
    #   processing the last item
    # @return [Enumerable] when no block is given
    def sequence
      return enum_for(:sequence) unless block_given?
      @data.length.times do |index|
        last = @data.length - 1
        if index == last
          yield(@data[index], Tuple.new)
        else
          yield(@data[index], Tuple.new(@data.slice(index+1..last)))
        end
      end
    end

    # Compares this object and other for equality. A tuple is `eql?` to
    # other when other is a tuple or an array-like object (any object that
    # responds to `to_a`) and the two objects have identical values in the
    # same foxed order.
    #
    # @param [Object] other the other tuple to compare for equality
    # @return [Boolean] true when equal else false
    def eql?(other)
      @data == other.to_a
    end
    alias_method :==, :eql?

    # Returns true if self contains no items.
    #
    # @return [Boolean] true when empty else false
    def empty?
      @data.empty?
    end

    # Returns the first element of the tuple or nil when empty.
    #
    # @return [Object] the first element or nil
    def first
      @data.first
    end
    alias_method :head, :first

    # Returns a tuple containing all the items in self after the first
    # item. Returns an empty tuple when empty or there is only one item.
    #
    # @return [Functional::Tuple] the tail of the tuple
    def rest
      if @data.length <= 1
        Tuple.new
      else
        Tuple.new(@data.slice(1..@data.length-1))
      end
    end
    alias_method :tail, :rest

    # Create a standard Ruby mutable array containing the tuple items
    # in the same order.
    #
    # @return [Array] the new array created from the tuple
    def to_a
      @data.dup
    end
    alias_method :to_ary, :to_a

    # Describe the contents of this object in a string.
    #
    # @return [String] the string representation of this object
    #
    # @!visibility private
    def inspect
      "#<#{self.class}: #{@data.to_s}>"
    end

    # Describe the contents of this object in a string that exactly
    # matches the string that would be created from an identical array.
    #
    # @return [String] the string representation of this object
    #
    # @!visibility private
    def to_s
      @data.to_s
    end
  end
end
