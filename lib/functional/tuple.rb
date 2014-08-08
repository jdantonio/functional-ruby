module Functional

  # @note The current implementation uses simple Ruby arrays. This is likely to be
  # very inefficient for all but the smallest tuples. The more elements the tuple
  # contains, the less efficient it will become. A future version will use a fast,
  # immutable, persistent data structure such as a finger tree or a trie.
  # 
  # @see http://en.wikipedia.org/wiki/Tuple
  # @see http://msdn.microsoft.com/en-us/library/system.tuple.aspx
  # @see http://www.tutorialspoint.com/python/python_tuples.htm
  # @see http://en.cppreference.com/w/cpp/utility/tuple
  # @see http://docs.oracle.com/javaee/6/api/javax/persistence/Tuple.html
  # @see http://www.erlang.org/doc/reference_manual/data_types.html
  # @see http://www.erlang.org/doc/man/erlang.html#make_tuple-2
  # @see http://en.wikibooks.org/wiki/Haskell/Lists_and_tuples#Tuples
  class Tuple

    def initialize(data = [])
      raise ArgumentError.new('data is not an array') unless data.respond_to?(:to_a)
      @data = data.to_a.dup.freeze
      self.freeze
    end

    def at(index)
      @data[index]
    end
    alias_method :nth, :at
    alias_method :[], :at

    def fetch(index, default)
      if index >= length || -index > length
        default
      else
        at(index)
      end
    end

    def length
      @data.length
    end
    alias_method :size, :length

    def intersect(other)
      Tuple.new(@data & other.to_a)
    end
    alias_method :&, :intersect

    def union(other)
      Tuple.new(@data | other.to_a)
    end
    alias_method :|, :union

    def concat(other)
      Tuple.new(@data + other.to_a)
    end
    alias_method :+, :concat

    def diff(other)
      Tuple.new(@data - other.to_a)
    end
    alias_method :-, :diff

    def repeat(multiple)
      multiple = multiple.to_i
      raise ArgumentError.new('negative argument') if multiple < 0
      Tuple.new(@data * multiple)
    end
    alias_method :*, :repeat

    def uniq
      Tuple.new(@data.uniq)
    end

    def each
      return enum_for(:each) unless block_given?
      @data.each do |item|
        yield(item)
      end
    end

    def each_with_index
      return enum_for(:each_with_index) unless block_given?
      @data.each_with_index do |item, index|
        yield(item, index)
      end
    end

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

    def eql?(other)
      @data == other.to_a
    end
    alias_method :==, :eql?

    def empty?
      @data.empty?
    end

    def first
      @data.first
    end
    alias_method :head, :first

    def rest
      if @data.empty?
        Tuple.new
      else
        Tuple.new(@data.slice(1..@data.length-1))
      end
    end
    alias_method :tail, :rest

    def to_a
      @data.dup
    end
    alias_method :to_ary, :to_a

    def inspect
      "#<#{self.class}: #{@data.to_s}>"
    end

    def to_s
      @data.to_s
    end
  end
end
