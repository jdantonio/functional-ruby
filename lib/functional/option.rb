require_relative 'abstract_struct'
require_relative 'protocol'

Functional::SpecifyProtocol(:Option) do
  instance_method :some?, 0
  instance_method :none?, 0
  instance_method :some, 0
end

module Functional
  class Option
    include AbstractStruct

    NO_OPTION = Object.new.freeze

    self.datatype = :option
    self.fields = [:some].freeze

    private_class_method :new

    class << self

      def none
        new(nil, true).freeze
      end

      def some(value)
        new(value, false).freeze
      end
    end

    def some?
      ! none?
    end

    def none?
      @none
    end

    def some
      to_h[:some]
    end

    def length
      none? ? 0 : 1
    end
    alias_method :size, :length

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

    private

    # @!visibility private 
    def initialize(value, none)
      @none = none
      hsh = none ? {some: nil} : {some: value}
      set_data_hash(hsh)
      set_values_array(hsh.values)
    end
  end
end
