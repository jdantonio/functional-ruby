require 'thread'

module Functional

  # An exception raised when an attempt is made to modify an
  # immutable object or attribute.
  FinalityError = Class.new(StandardError)

  class FinalVar

    NO_VALUE = Object.new.freeze

    def initialize(value = NO_VALUE)
      if value == NO_VALUE
        @set = false
        @value = nil
      else
        @set = true
        @value = value
      end
    end

    def get
      @value
    end
    alias_method :value, :get

    def set(value)
      if @set
        raise FinalityError.new('value has already been set')
      else
        @set = true
        @value = value
      end
    end
    alias_method :value=, :set

    def set?
      @set
    end
    alias_method :value?, :set?

    def get_or_set(value)
      if @set
        @value
      else
        @value = value
      end
    end

    def fetch(default)
      @set ? @value : default
    end

    def eql?(other)
      if ! set?
        false
      elsif other.is_a?(FinalVar)
        value == other.value
      else
        value == other
      end
    end
    alias_method :==, :eql?

    def inspect
      val = set? ? "value=#{value.is_a?(String) ? ('"' + value + '"') : value }" : 'unset'
      "#<#{self.class} #{val}>"
    end

    def to_s
      value.to_s
    end
  end
end
