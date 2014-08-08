require 'thread'

module Functional

  # An exception raised when an attempt is made to modify an
  # immutable object or attribute.
  FinalityError = Class.new(StandardError)

  class FinalVar

    NO_VALUE = Object.new.freeze

    def initialize(value = NO_VALUE)
      @mutex = Mutex.new
      @value = value
    end

    def get
      @mutex.synchronize {
        has_been_set? ? @value : nil
      }
    end
    alias_method :value, :get

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

    def set?
      @mutex.synchronize {
        has_been_set?
      }
    end
    alias_method :value?, :set?

    def get_or_set(value)
      @mutex.synchronize {
        if has_been_set?
          @value
        else
          @value = value
        end
      }
    end

    def fetch(default)
      @mutex.synchronize {
        has_been_set? ? @value : default
      }
    end

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

    def inspect
      if (val = fetch(NO_VALUE)) == NO_VALUE
        val = 'unset'
      else
        val = "value=#{val.is_a?(String) ? ('"' + val + '"') : val }"
      end
      "#<#{self.class} #{val}>"
    end

    def to_s
      value.to_s
    end

    private

    def has_been_set?
      @value != NO_VALUE
    end
  end
end
