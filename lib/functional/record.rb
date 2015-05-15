require 'functional/abstract_struct'
require 'functional/protocol'
require 'functional/type_check'

module Functional

  # An immutable data structure with multiple data fields. A `Record` is a
  # convenient way to bundle a number of field attributes together,
  # using accessor methods, without having to write an explicit class.
  # The `Record` module generates new `AbstractStruct` subclasses that hold a
  # set of fields with a reader method for each field.
  #
  # A `Record` is very similar to a Ruby `Struct` and shares many of its behaviors
  # and attributes. Unlike a # Ruby `Struct`, a `Record` is immutable: its values
  # are set at construction and can never be changed. Divergence between the two
  # classes derive from this core difference.
  #
  # {include:file:doc/record.md}
  #
  # @see Functional::Union
  # @see Functional::Protocol
  # @see Functional::TypeCheck
  #
  # @!macro thread_safe_immutable_object
  module Record
    extend self

    # Create a new record class with the given fields.
    #
    # @return [Functional::AbstractStruct] the new record subclass
    # @raise [ArgumentError] no fields specified or an invalid type
    #   specification is given
    def new(*fields, &block)
      raise ArgumentError.new('no fields provided') if fields.empty?

      name = nil
      types = nil

      # check if a name for registration is given
      if fields.first.is_a?(String)
        name = fields.first
        fields = fields[1..fields.length-1]
      end

      # check for a set of type/protocol specifications
      if fields.size == 1 && fields.first.respond_to?(:to_h)
        types = fields.first
        fields = fields.first.keys
        check_types!(types)
      end

      build(name, fields, types, &block)
    rescue
      raise ArgumentError.new('invalid specification')
    end

    private

    # @!visibility private
    #
    # A set of restrictions governing the creation of a new record.
    class Restrictions
      include Protocol
      include TypeCheck

      # Create a new restrictions object by processing the given
      # block. The block should be the DSL for defining a record class.
      #
      # @param [Hash] types a hash of fields and the associated type/protocol
      #   when type/protocol checking is among the restrictions
      # @param [Proc] block A DSL definition of a new record.
      # @yield A DSL definition of a new record.
      def initialize(types = nil, &block)
        @types = types
        @required = []
        @defaults = {}
        instance_eval(&block) if block_given?
        @required.freeze
        @defaults.freeze
        self.freeze
      end

      # DSL method for declaring one or more fields to be mandatory.
      #
      # @param [Symbol] fields zero or more mandatory fields
      def mandatory(*fields)
        @required.concat(fields.collect{|field| field.to_sym})
      end

      # DSL method for declaring a default value for a field
      #
      # @param [Symbol] field the field to be given a default value
      # @param [Object] value the default value of the field
      def default(field, value)
        @defaults[field] = value
      end

      # Clone a default value if it is cloneable. Else just return
      # the value.
      #
      # @param [Symbol] field the name of the field from which the
      #   default value is to be cloned.
      # @return [Object] a clone of the value or the value if uncloneable
      def clone_default(field)
        value = @defaults[field]
        value = value.clone unless uncloneable?(value)
      rescue TypeError
        # can't be cloned
      ensure
        return value
      end

      # Validate the record data against this set of restrictions.
      #
      # @param [Hash] data the data hash
      # @raise [ArgumentError] when the data does not match the restrictions
      def validate!(data)
        validate_mandatory!(data)
        validate_types!(data)
      end

      private

      # Check the given data hash to see if it contains non-nil values for
      # all mandatory fields.
      #
      # @param [Hash] data the data hash
      # @raise [ArgumentError] if any mandatory fields are missing
      def validate_mandatory!(data)
        if data.any?{|k,v| @required.include?(k) && v.nil? }
          raise ArgumentError.new('mandatory fields must not be nil')
        end
      end

      # Validate the record data against a type/protocol specification.
      #
      # @param [Hash] data the data hash
      # @raise [ArgumentError] when the data does not match the specification
      def validate_types!(data)
        return if @types.nil?
        @types.each do |field, type|
          value = data[field]
          next if value.nil?
          if type.is_a? Module
            raise ArgumentError.new("'#{field}' must be of type #{type}") unless Type?(value, type)
          else
            raise ArgumentError.new("'#{field}' must stasify the protocol :#{type}") unless Satisfy?(value, type)
          end
        end
      end

      # Is the given object uncloneable?
      #
      # @param [Object] object the object to check
      # @return [Boolean] true if the object cannot be cloned else false
      def uncloneable?(object)
        Type? object, NilClass, TrueClass, FalseClass, Fixnum, Bignum, Float
      end
    end
    private_constant :Restrictions

    # Validate the given type/protocol specification.
    #
    # @param [Hash] types the type specification
    # @raise [ArgumentError] when the specification is not valid
    def check_types!(types)
      return if types.nil?
      unless types.all?{|k,v| v.is_a?(Module) || v.is_a?(Symbol) }
        raise ArgumentError.new('invalid specification')
      end
    end

    # Use the given `AbstractStruct` class and build the methods necessary
    # to support the given data fields.
    #
    # @param [String] name the name under which to register the record when given
    # @param [Array] fields the list of symbolic names for all data fields
    # @return [Functional::AbstractStruct] the record class
    def build(name, fields, types, &block)
      fields = [name].concat(fields) unless name.nil?
      record, fields = AbstractStruct.define_class(self, :record, fields)
      record.class_variable_set(:@@restrictions, Restrictions.new(types, &block))
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
        super()
        restrictions = record.class_variable_get(:@@restrictions)
        data = record.fields.reduce({}) do |memo, field|
          memo[field] = data.fetch(field, restrictions.clone_default(field))
          memo
        end
        restrictions.validate!(data)
        set_data_hash(data)
        set_values_array(data.values)
        ensure_ivar_visibility!
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
