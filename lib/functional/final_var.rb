require_relative 'final'

module Functional

  class FinalVar
    include Final

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
        Functional::Final::raise_final_attr_already_set_error(:value)
      else
        @value = value
        @set = true
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
  end
end
