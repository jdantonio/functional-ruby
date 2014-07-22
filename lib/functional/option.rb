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
    alias_method :value?, :some?
    alias_method :fulfilled?, :some?

    def none?
      @none
    end
    alias_method :reason?, :none?
    alias_method :rejected?, :none?

    def some
      to_h[:some]
    end
    alias_method :value, :some

    def reason
      some? ? nil : :none
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

    def inspect
      super.gsub(/ :some/, " (#{some? ? 'some' : 'none'}) :some")
    end
    alias_method :to_s, :inspect

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
