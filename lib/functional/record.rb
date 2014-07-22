require_relative 'abstract_struct'

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
  # @see http://clojure.org/datatypes
  # @see http://clojure.github.io/clojure/clojure.core-api.html#clojure.core/defrecord
  # @see http://www.erlang.org/doc/reference_manual/records.html
  # @see http://www.erlang.org/doc/programming_examples/records.html
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

    class RestrictionsProcessor
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
    end

    # Use the given `AbstractStruct` class and build the methods necessary
    # to support the given data fields.
    #
    # @param [Array] fields the list of symbolic names for all data fields
    # @return [Functional::AbstractStruct] the record class
    def build(fields, &block)
      fields = fields.collect{|field| field.to_sym }.freeze
      record = Class.new{ include AbstractStruct }
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
          memo[field] = data.fetch(field, restrictions.defaults[field])
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
