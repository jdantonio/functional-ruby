require_relative 'abstract_struct'
require_relative 'type_check'

module Functional

  # {include:file:doc/record.md}
  #
  # @see Functional::AbstractStruct
  # @see Functional::Union
  # @see http://www.ruby-doc.org/core-2.1.2/Struct.html Ruby `Struct` class
  module Record
    extend self

    # Create a new record class with the given fields.
    #
    # @return [Functional::AbstractStruct] the new record subclass
    # @raise [ArgumentError] no fields specified
    def new(*fields, &block)
      raise ArgumentError.new('no fields provided') if fields.empty?
      build(fields, &block)
    end

    private

    # @!visibility private
    class RestrictionsProcessor
      include TypeCheck
      attr_reader :required
      attr_reader :defaults

      def mandatory(*fields)
        @required.concat(fields.collect{|field| field.to_sym})
      end

      def default(field, value)
        @defaults[field] = value
      end

      def initialize(&block)
        @required = []
        @defaults = {}
        instance_eval(&block) if block_given?
        @required.freeze
        @defaults.freeze
        self.freeze
      end

      def clone_default(field)
        value = @defaults[field]
        value = value.clone unless uncloneable?(value)
      rescue TypeError
        # can't be cloned
      ensure
        return value
      end

      private

      def uncloneable?(object)
        Type? object, NilClass, TrueClass, FalseClass, Fixnum, Bignum, Float
      end
    end

    # Use the given `AbstractStruct` class and build the methods necessary
    # to support the given data fields.
    #
    # @param [Array] fields the list of symbolic names for all data fields
    # @return [Functional::AbstractStruct] the record class
    def build(fields, &block)
      record = Class.new{ include AbstractStruct }
      if fields.first.is_a? String
        self.const_set(fields.first, record)
        fields = fields[1, fields.length-1]
      end
      fields = fields.collect{|field| field.to_sym }.freeze
      record.send(:datatype=, :record)
      record.send(:fields=, fields)
      record.class_variable_set(:@@restrictions, RestrictionsProcessor.new(&block))
      define_initializer(record)
      fields.each do |field|
        define_reader(record, field)
      end
      record
    end

    # Define an initializer method on the given record class.
    #
    # @param [Functional::AbstractStruct] record the new record class
    # @return [Functional::AbstractStruct] the record class
    def define_initializer(record)
      record.send(:define_method, :initialize) do |data = {}|
        restrictions = self.class.class_variable_get(:@@restrictions)
        data = fields.reduce({}) do |memo, field|
          memo[field] = data.fetch(field, restrictions.clone_default(field))
          memo
        end
        if data.any?{|k,v| restrictions.required.include?(k) && v.nil? }
          raise ArgumentError.new('mandatory fields must not be nil')
        end
        set_data_hash(data)
        set_values_array(data.values)
        self.freeze
      end
      record
    end

    # Define a reader method on the given record class for the given data field.
    #
    # @param [Functional::AbstractStruct] record the new record class
    # @param [Symbol] field symbolic name of the current data field
    # @return [Functional::AbstractStruct] the record class
    def define_reader(record, field)
      record.send(:define_method, field) do
        to_h[field]
      end
      record
    end
  end
end
