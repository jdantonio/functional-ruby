require 'thread'

module Functional

  # An exception raised when an attempt is made to modify an
  # immutable object or attribute.
  FinalityError = Class.new(StandardError)

  # A thread safe object that holds a single value and is "final" (meaning
  # that the value can be set at most once after which it becomes immutable).
  # The value can be set at instantiation which will result in the object
  # becoming fully and immediately immutable. Attempting to set the value
  # once it has been set is a logical error and will result in an exception
  # being raised.
  #
  # @example Instanciation With No Value
  #   f = Functional::FinalVar.new
  #     #=> #<Functional::FinalVar unset>
  #   f.set?       #=> false
  #   f.value      #=> nil
  #   f.value = 42 #=> 42
  #   f.inspect
  #     #=> "#<Functional::FinalVar value=42>"
  #   f.set?       #=> true
  #   f.value      #=> 42
  #
  # @example Instanciation With an Initial Value
  #   f = Functional::FinalVar.new(42)
  #     #=> #<Functional::FinalVar value=42>
  #   f.set?       #=> true
  #   f.value      #=> 42
  #
  # @since 1.1.0
  #
  # @see Functional::FinalStruct
  # @see http://en.wikipedia.org/wiki/Final_(Java) Java `final` keyword
  #
  # @!macro [new] thread_safe_final_object
  #
  #   @note This is a write-once, read-many, thread safe object that can
  #     be used in concurrent systems. Thread safety guarantees *cannot* be made
  #     about objects contained *within* this object, however. Ruby variables are
  #     mutable references to mutable objects. This cannot be changed. The best
  #     practice it to only encapsulate immutable, frozen, or thread safe objects.
  #     Ultimately, thread safety is the responsibility of the programmer.
  class FinalVar

    # @!visibility private
    NO_VALUE = Object.new.freeze

    # Create a new `FinalVar` with the given value or "unset" when
    # no value is given.
    #
    # @param [Object] value if given, the immutable value of the object
    def initialize(value = NO_VALUE)
      @mutex = Mutex.new
      @value = value
    end

    # Get the current value or nil if unset.
    #
    # @return [Object] the current value or nil
    def get
      @mutex.synchronize {
        has_been_set? ? @value : nil
      }
    end
    alias_method :value, :get

    # Set the value. Will raise an exception if already set.
    #
    # @param [Object] value the value to set
    # @return [Object] the new value
    # @raise [Functional::FinalityError] if the value has already been set
    def set(value)
      @mutex.synchronize {
        if has_been_set?
          raise FinalityError.new('value has already been set')
        else
          @value = value
        end
      }
    end
    alias_method :value=, :set

    # Has the value been set?
    #
    # @return [Boolean] true when the value has been set else false
    def set?
      @mutex.synchronize {
        has_been_set?
      }
    end
    alias_method :value?, :set?

    # Get the value if it has been set else set the value.
    #
    # @param [Object] value the value to set
    # @return [Object] the current value if already set else the new value
    def get_or_set(value)
      @mutex.synchronize {
        if has_been_set?
          @value
        else
          @value = value
        end
      }
    end

    # Get the value if set else return the given default value.
    #
    # @param [Object] default the value to return if currently unset
    # @return [Object] the current value when set else the given default
    def fetch(default)
      @mutex.synchronize {
        has_been_set? ? @value : default
      }
    end

    # Compares this object and other for equality. A `FinalVar` that is unset
    # is never equal to anything else (it represents a complete absence of value).
    # When set a `FinalVar` is equal to another `FinalVar` if they have the same
    # value. A `FinalVar` is equal to another object if its value is equal to
    # the other object using Ruby's normal equality rules.
    #
    # @param [Object] other the object to compare equality to
    # @return [Boolean] true if equal else false
    def eql?(other)
      if (val = fetch(NO_VALUE)) == NO_VALUE
        false
      elsif other.is_a?(FinalVar)
        val == other.value
      else
        val == other
      end
    end
    alias_method :==, :eql?

    # Describe the contents of this object in a string.
    #
    # @return [String] the string representation of this object
    #
    # @!visibility private
    def inspect
      if (val = fetch(NO_VALUE)) == NO_VALUE
        val = 'unset'
      else
        val = "value=#{val.is_a?(String) ? ('"' + val + '"') : val }"
      end
      "#<#{self.class} #{val}>"
    end

    # Describe the contents of this object in a string.
    #
    # @return [String] the string representation of this object
    #
    # @!visibility private
    def to_s
      value.to_s
    end

    private

    # Checks the set status without locking the mutex.
    # @return [Boolean] true when set else false
    def has_been_set?
      @value != NO_VALUE
    end
  end
end
