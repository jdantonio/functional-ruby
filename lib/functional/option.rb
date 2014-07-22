require_relative 'abstract_struct'
require_relative 'protocol'

Functional::SpecifyProtocol(:Option) do
  instance_method :some?, 0
  instance_method :none?, 0
  instance_method :some, 0
  class_method :some, 1
  class_method :none, 0
end

module Functional
  class Option
    include AbstractStruct

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
