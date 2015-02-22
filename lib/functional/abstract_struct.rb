require_relative 'protocol'

Functional::SpecifyProtocol(:Struct) do
  instance_method :fields
  instance_method :values
  instance_method :length
  instance_method :each
  instance_method :each_pair
end

module Functional

  # An abstract base class for immutable struct classes.
  #
  # @since 1.0.0
  module AbstractStruct

    # @return [Array] the values of all record fields in order, frozen
    attr_reader :values

    # Yields the value of each record field in order.
    # If no block is given an enumerator is returned.
    #
    # @yieldparam [Object] value the value of the given field
    #
    # @return [Enumerable] when no block is given
    def each
      return enum_for(:each) unless block_given?
      fields.each do |field|
        yield(self.send(field))
      end
    end

    # Yields the name and value of each record field in order.
    # If no block is given an enumerator is returned.
    #
    # @yieldparam [Symbol] field the record field for the current iteration
    # @yieldparam [Object] value the value of the current field
    #
    # @return [Enumerable] when no block is given
    def each_pair
      return enum_for(:each_pair) unless block_given?
      fields.each do |field|
        yield(field, self.send(field))
      end
    end

    # Equality--Returns `true` if `other` has the same record subclass and has equal
    # field values (according to `Object#==`).
    #
    # @param [Object] other the other record to compare for equality
    # @return [Boolean] true when equal else false
    def eql?(other)
      self.class == other.class && self.to_h == other.to_h
    end
    alias_method :==, :eql?

    # @!macro [attach] inspect_method
    #
    #   Describe the contents of this struct in a string. Will include the name of the
    #   record class, all fields, and all values.
    #
    #   @return [String] the class and contents of this record
    def inspect
      state = to_h.to_s.gsub(/^{/, '').gsub(/}$/, '')
      "#<#{self.class.datatype} #{self.class} #{state}>"
    end
    alias_method :to_s, :inspect

    # Returns the number of record fields.
    #
    # @return [Fixnum] the number of record fields
    def length
      fields.length
    end
    alias_method :size, :length

    # A frozen array of all record fields.
    #
    # @return [Array] all record fields in order, frozen
    def fields
      self.class.fields
    end

    # Returns a Hash containing the names and values for the record’s fields.
    #
    # @return [Hash] collection of all fields and their associated values
    def to_h
      @data
    end

    protected

    # Set the internal data hash to a copy of the given hash and freeze it.
    # @param [Hash] data the data hash
    #
    # @!visibility private
    def set_data_hash(data)
      @data = data.dup.freeze
    end

    # Set the internal values array to a copy of the given array and freeze it.
    # @param [Array] values the values array
    #
    # @!visibility private
    def set_values_array(values)
      @values = values.dup.freeze
    end

    # Define a new struct class and, if necessary, register it with
    # the calling class/module. Will also set the datatype and fields
    # class attributes on the new struct class.
    #
    # @param [Module] parent the class/module that is defining the new struct
    # @param [Symbol] datatype the datatype value for the new struct class
    # @param [Array] fields the list of symbolic names for all data fields
    # @return [Functional::AbstractStruct, Array] the new class and the
    #   (possibly) updated fields array
    #
    # @!visibility private
    def self.define_class(parent, datatype, fields)
      struct = Class.new{ include AbstractStruct }
      if fields.first.is_a? String
        parent.const_set(fields.first, struct)
        fields = fields[1, fields.length-1]
      end
      fields = fields.collect{|field| field.to_sym }.freeze
      struct.send(:datatype=, datatype.to_sym)
      struct.send(:fields=, fields)
      [struct, fields]
    end

    private

    def self.included(base)
      base.extend(ClassMethods)
      super(base)
    end

    # Class methods added to a class that includes {Functional::PatternMatching}
    #
    # @!visibility private
    module ClassMethods

      # A frozen Array of all record fields in order
      attr_reader :fields

      # A symbol describing the object's datatype
      attr_reader :datatype

      private

      # A frozen Array of all record fields in order
      attr_writer :fields

      # A symbol describing the object's datatype
      attr_writer :datatype

      fields = [].freeze
      datatype = :struct
    end
  end
end
