module Functional

  # An abstract base class for immutable struct classes.
  class AbstractStruct

    # @return [Array] the values of all record members in order, frozen
    attr_reader :values

    class << self

      # @return [Array] all record members in order, frozen
      attr_reader :members

      # @return [Symbol] a symbol describing the object's datatype
      attr_reader :datatype

      protected

      # @!visibility private
      attr_writer :members

      # @!visibility private
      attr_writer :datatype
    end

    self.members = [].freeze
    self.datatype = :struct

    # Yields the value of each record member in order.
    # If no block is given an enumerator is returned.
    #
    # @yieldparam [Object] value the value of the given member
    #
    # @return [Enumerable] when no block is given
    def each
      return enum_for(:each) unless block_given?
      members.each do |member|
        yield(self.send(member))
      end
    end

    # Yields the name and value of each record member in order.
    # If no block is given an enumerator is returned.
    #
    # @yieldparam [Symbol] member the record member for the current iteration
    # @yieldparam [Object] value the value of the current member
    #
    # @return [Enumerable] when no block is given
    def each_pair
      return enum_for(:each_pair) unless block_given?
      members.each do |member|
        yield(member, self.send(member))
      end
    end

    # Equality--Returns `true` if `other` has the same record subclass and has equal
    # member values (according to `Object#==`).
    #
    # @param [Object] other the other record to compare for equality
    # @return [Booleab] true when equal else false
    def eql?(other)
      self.class == other.class && self.to_h == other.to_h
    end
    alias_method :==, :eql?

    # Describe the contents of this record in a string. Will include the name of the
    # record class, all members, and all values.
    #
    # @return [String] the class and contents of this record
    def inspect
      state = to_h.to_s.gsub(/^{/, '').gsub(/}$/, '')
      "#<#{self.class.datatype} #{self.class} #{state}>"
    end
    alias_method :to_s, :inspect

    # Returns the number of record members.
    #
    # @return [Fixnum] the number of record members
    def length
      members.length
    end
    alias_method :size, :length

    # A frozen array of all record members.
    #
    # @return [Array] all record members in order, frozen
    def members
      self.class.members
    end

    # Returns a Hash containing the names and values for the record’s members.
    #
    # @return [Hash] collection of all members and their associated values
    def to_h
      @data
    end

    # @!visibility private
    private_class_method :new

    protected

    def set_data_hash(data)
      @data = data.freeze
    end

    def set_values_array(values)
      @values = values.freeze
    end

    def self.set_datatype(datatype)
      self.datatype = datatype
    end
  end
end
