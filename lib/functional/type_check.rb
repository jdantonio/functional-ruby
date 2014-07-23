module Functional

  # Supplies type-checking helpers whenever included.
  #
  # @see http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Actor/TypeCheck.html TypeCheck in Concurrent Ruby
  module TypeCheck

    # Performs an `is_a?` check of the given value object against the
    # given list of modules and/or classes.
    #
    # @param [Object] value the object to interrogate
    # @param [Module] types zero or more modules and/or classes to check
    #   the value against
    # @return [Boolean] true on success
    def Type?(value, *types)
      types.any? { |t| value.is_a? t }
    end
    module_function :Type?

    # Performs an `is_a?` check of the given value object against the
    # given list of modules and/or classes. Raises an exception on failure.
    #
    # @param [Object] value the object to interrogate
    # @param [Module] types zero or more modules and/or classes to check
    #   the value against
    # @return [Object] the value object
    #
    # @raise [Functional::TypeError] when the check fails
    def Type!(value, *types)
      Type?(value, *types) or
        TypeCheck.error(value, 'is not', types)
      value
    end
    module_function :Type!

    # Is the given value object is an instance of or descendant of
    # one of the classes/modules in the given list?
    #
    # Performs the check using the `===` operator.
    #
    # @param [Object] value the object to interrogate
    # @param [Module] types zero or more modules and/or classes to check
    #   the value against
    # @return [Boolean] true on success
    def Match?(value, *types)
      types.any? { |t| t === value }
    end
    module_function :Match?

    # Is the given value object is an instance of or descendant of
    # one of the classes/modules in the given list?  Raises an exception
    # on failure.
    #
    # Performs the check using the `===` operator.
    #
    # @param [Object] value the object to interrogate
    # @param [Module] types zero or more modules and/or classes to check
    #   the value against
    # @return [Object] the value object
    #
    # @raise [Functional::TypeError] when the check fails
    def Match!(value, *types)
      Match?(value, *types) or
        TypeCheck.error(value, 'is not matching', types)
      value
    end
    module_function :Match!

    # Is the given class a subclass or exact match of one or more
    # of the modules and/or classes in the given list?
    #
    # @param [Class] value the class to interrogate
    # @param [Class] types zero or more classes to check the value against
    #   the value against
    # @return [Boolean] true on success
    def Child?(value, *types)
      Type?(value, Class) &&
        types.any? { |t| value <= t }
    end
    module_function :Child?

    # Is the given class a subclass or exact match of one or more
    # of the modules and/or classes in the given list?
    #
    # @param [Class] value the class to interrogate
    # @param [Class] types zero or more classes to check the value against
    # @return [Class] the value class
    #
    # @raise [Functional::TypeError] when the check fails
    def Child!(value, *types)
      Child?(value, *types) or
        TypeCheck.error(value, 'is not child', types)
      value
    end
    module_function :Child!

    private

    # Create a {Functional::TypeError} object from the given data.
    #
    # @param [Object] value the class/method that was being interrogated
    # @param [String] message the message fragment to inject into the error
    # @param [Object] types list of modules and/or classes that were being
    #   checked against the value object
    #
    # @raise [Functional::TypeError] the formatted exception object
    def self.error(value, message, types)
      raise TypeError,
        "Value (#{value.class}) '#{value}' #{message} any of: #{types.join('; ')}."
    end
  end
end
