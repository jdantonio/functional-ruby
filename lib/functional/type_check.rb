module Functional

  # Supplies type-checking helpers whenever included.
  #
  # @see http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Actor/TypeCheck.html
  module TypeCheck

    def Type?(value, *types)
      types.any? { |t| value.is_a? t }
    end
    module_function :Type?

    def Type!(value, *types)
      Type?(value, *types) or
        TypeCheck.error(value, 'is not', types)
      value
    end
    module_function :Type!

    def Match?(value, *types)
      types.any? { |t| t === value }
    end
    module_function :Match?

    def Match!(value, *types)
      Match?(value, *types) or
        TypeCheck.error(value, 'is not matching', types)
      value
    end
    module_function :Match!

    def Child?(value, *types)
      Type?(value, Class) &&
        types.any? { |t| value <= t }
    end
    module_function :Child?

    def Child!(value, *types)
      Child?(value, *types) or
        TypeCheck.error(value, 'is not child', types)
      value
    end
    module_function :Child!

    private

    def self.error(value, message, types)
      raise TypeError,
        "Value (#{value.class}) '#{value}' #{message} any of: #{types.join('; ')}."
    end
  end
end
