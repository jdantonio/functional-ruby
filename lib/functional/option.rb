require 'functional/abstract_struct'
require 'functional/either'
require 'functional/protocol'
require 'functional/synchronization'

Functional::SpecifyProtocol(:Option) do
  instance_method :some?, 0
  instance_method :none?, 0
  instance_method :some, 0
end

module Functional

  # An optional value that may be none (no value) or some (a value).
  # This type is a replacement for the use of nil with better type checks. 
  # It is an immutable data structure that extends `AbstractStruct`.
  #
  # @see Functional::AbstractStruct
  # @see http://functionaljava.googlecode.com/svn/artifacts/3.0/javadoc/index.html Functional Java
  #
  # @!macro thread_safe_immutable_object
  class Option < Synchronization::Object
    include AbstractStruct

    # @!visibility private 
    NO_OPTION = Object.new.freeze

    self.datatype = :option
    self.fields = [:some].freeze

    private_class_method :new

    # The reason for the absence of a value when none,
    # defaults to nil
    attr_reader :reason

    class << self

      # Construct an `Option` with no value.
      #
      # @return [Option] the new option
      def none(reason = nil)
        new(nil, true, reason).freeze
      end

      # Construct an `Option` with the given value.
      #
      # @param [Object] value the value of the option
      # @return [Option] the new option
      def some(value)
        new(value, false).freeze
      end
    end

    # Does the option have a value?
    #
    # @return [Boolean] true if some else false
    def some?
      ! none?
    end
    alias_method :value?, :some?
    alias_method :fulfilled?, :some?

    # Is the option absent a value?
    #
    # @return [Boolean] true if none else false
    def none?
      @none
    end
    alias_method :reason?, :none?
    alias_method :rejected?, :none?

    # The value of this option.
    #
    # @return [Object] the value when some else nil
    def some
      to_h[:some]
    end
    alias_method :value, :some

    # Returns the length of this optional value;
    # 1 if there is a value, 0 otherwise. 
    #
    # @return [Fixnum] The length of this optional value;
    #   1 if there is a value, 0 otherwise.
    def length
      none? ? 0 : 1
    end
    alias_method :size, :length

    # Perform a logical `and` operation against this option and the
    # provided option or block. Returns true if this option is some and:
    #
    # * other is an `Option` with some value
    # * other is a truthy value (not nil or false)
    # * the result of the block is a truthy value
    #
    # If a block is given the value of the current option is passed to the
    # block and the result of block processing will be evaluated for its
    # truthiness. An exception will be raised if an other value and a
    # block are both provided.
    #
    # @param [Object] other the value to be evaluated against this option
    # @yieldparam [Object] value the value of this option when some
    # @return [Boolean] true when the union succeeds else false
    # @raise [ArgumentError] when given both other and a block
    def and(other = NO_OPTION)
      raise ArgumentError.new('cannot give both an option and a block') if other != NO_OPTION && block_given?
      return false if none?

      if block_given?
        !! yield(some)
      elsif Protocol::Satisfy? other, :Option
        other.some?
      else
        !! other
      end
    end

    # Perform a logical `or` operation against this option and the
    # provided option or block. Returns true if this option is some.
    # If this option is none it returns true if:
    #
    # * other is an `Option` with some value
    # * other is a truthy value (not nil or false)
    # * the result of the block is a truthy value
    #
    # If a block is given the value of the result of block processing
    # will be evaluated for its truthiness. An exception will be raised
    # if an other value and a block are both provided.
    #
    # @param [Object] other the value to be evaluated against this option
    # @return [Boolean] true when the intersection succeeds else false
    # @raise [ArgumentError] when given both other and a block
    def or(other = NO_OPTION)
      raise ArgumentError.new('cannot give both an option and a block') if other != NO_OPTION && block_given?
      return true if some?

      if block_given?
        !! yield
      elsif Protocol::Satisfy? other, :Option
        other.some?
      else
        !! other
      end
    end

    # Returns the value of this option when some else returns the
    # value of the other option or block. When the other is also an
    # option its some value is returned. When the other is any other
    # value it is simply passed through. When a block is provided the
    # block is processed and the return value of the block is returned.
    # An exception will be raised if an other value and a block are
    # both provided.
    #
    # @param [Object] other the value to be evaluated when this is none
    # @return [Object] this value when some else the value of other
    # @raise [ArgumentError] when given both other and a block
    def else(other = NO_OPTION)
      raise ArgumentError.new('cannot give both an option and a block') if other != NO_OPTION && block_given?
      return some if some?

      if block_given?
        yield
      elsif Protocol::Satisfy? other, :Option
        other.some
      else
        other
      end
    end

    # If the condition satisfies, return the given A in some, otherwise, none.
    #
    # @param [Object] value The some value to use if the condition satisfies.
    # @param [Boolean] condition The condition to test (when no block given).
    # @yield The condition to test (when no condition given).
    #
    # @return [Option] A constructed option based on the given condition.
    #
    # @raise [ArgumentError] When both a condition and a block are given.
    def self.iff(value, condition = NO_OPTION)
      raise ArgumentError.new('requires either a condition or a block, not both') if condition != NO_OPTION && block_given?
      condition = block_given? ? yield : !! condition
      condition ? some(value) : none
    end

    # @!macro inspect_method
    def inspect
      super.gsub(/ :some/, " (#{some? ? 'some' : 'none'}) :some")
    end
    alias_method :to_s, :inspect

    private

    # Create a new Option with the given value and disposition.
    #
    # @param [Object] value the value of this option
    # @param [Boolean] none is this option absent a value?
    # @param [Object] reason the reason for the absense of a value
    #
    # @!visibility private 
    def initialize(value, none, reason = nil)
      super
      @none = none
      @reason = none ? reason : nil
      hsh = none ? {some: nil} : {some: value}
      set_data_hash(hsh)
      set_values_array(hsh.values)
      ensure_ivar_visibility!
    end
  end
end
