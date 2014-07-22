require_relative 'abstract_struct'

module Functional

  # An immutable data structure with multiple data members. A `Record` is a
  # convenient way to bundle a number of member attributes together,
  # using accessor methods, without having to write an explicit class.
  # The `Record` module generates new `AbstractStruct` subclasses that hold a
  # set of members with a reader method for each member.
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

    # Create a new record class with the given members.
    #
    # @return [Functional::AbstractStruct] the new record subclass
    # @raise [ArgumentError] no members specified
    def new(*members, &block)
      raise ArgumentError.new('no members provided') if members.empty?
      build(members, &block)
    end

    private

    class RestrictionsProcessor
      attr_reader :required
      attr_reader :defaults

      def mandatory(*members)
        @required.concat(members.collect{|member| member.to_sym})
      end

      def default(member, value)
        @defaults[member] = value
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
    # to support the given data members.
    #
    # @param [Functional::AbstractStruct] record the new record class
    # @param [Array] members the list of symbolic names for all data members
    # @return [Functional::AbstractStruct] the record class
    def build(members, &block)
      members = members.collect{|member| member.to_sym }.freeze
      record = Class.new{ include AbstractStruct }
      record.send(:datatype=, :record)
      record.send(:members=, members)
      record.class_variable_set(:@@restrictions, RestrictionsProcessor.new(&block))
      define_initializer(record)
      members.each do |member|
        define_reader(record, member)
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
        data = members.reduce({}) do |memo, member|
          memo[member] = data.fetch(member, restrictions.defaults[member])
          memo
        end
        if data.any?{|k,v| restrictions.required.include?(k) && v.nil? }
          raise ArgumentError.new('mandatory members must not be nil')
        end
        set_data_hash(data)
        set_values_array(data.values)
        self.freeze
      end
      record
    end

    # Define a reader method on the given record class for the given data member.
    #
    # @param [Functional::AbstractStruct] record the new record class
    # @param [Symbol] member symbolic name of the current data member
    # @return [Functional::AbstractStruct] the record class
    def define_reader(record, member)
      record.send(:define_method, member) do
        to_h[member]
      end
      record
    end
  end
end
