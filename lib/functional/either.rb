module Functional

  # The `Either` type represents a value of one of two possible types (a disjoint union).
  # The data constructors; `left` and `right` represent the two possible values.
  # The `Either` type is often used as an alternative to `Option` where `left` represents
  # failure (by convention) and `right` is akin to `some`. To reinforce this convention
  # the aliases `reason` and `value` are provided. The semantics of these aliases align
  # with the `Obligation` mixin of the Concurrent Ruby library.
  #
  # @see http://functionaljava.googlecode.com/svn/artifacts/3.0/javadoc/fj/data/Either.html Functional Java
  # @see http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Obligation.html Concurrent Ruby
  class Either

    # @!visibility private 
    NO_VALUE = Object.new

    attr_reader :left, :right

    alias_method :reason, :left
    alias_method :value, :right

    ### class methods

    # Construct a left value of either.
    #
    # @param [Object] value The value underlying the either.
    # @return [Either] A new either with the given left value.
    def self.left(value)
      new(value, nil, true).freeze
    end

    # Construct a right value of either.
    #
    # @param [Object] value The value underlying the either.
    # @return [Either] A new either with the given right value.
    def self.right(value)
      new(nil, value, false).freeze
    end

    class << self
      alias_method :reason, :left
      alias_method :value, :right
    end

    private_class_method :new

    ### instance methods

    # Returns true if this either is a left, false otherwise.
    #
    # @return [Boolean] `true` if this either is a left, `false` otherwise.
    def left?
      @is_left
    end
    alias_method :reason?, :left?

    # Returns true if this either is a right, false otherwise.
    #
    # @return [Boolean] `true` if this either is a right, `false` otherwise.
    def right?
      ! left?
    end
    alias_method :value?, :right?

    # If this is a left, then return the left value in right, or vice versa.
    #
    # @return [Either] The value of this either swapped to the opposing side.
    def swap
      self.class.send(:new, @right, @left, ! @is_left)
    end

    # The value of this either swapped to the opposing side.
    #
    # @param [Proc] lproc The function to call if this is left.
    # @param [Proc] rproc The function to call if this is right.
    # @return [Object] The reduced value.
    def either(lproc, rproc)
      left? ? lproc.call(left) : rproc.call(right)
    end

    # If the condition satisfies, return the given A in left, otherwise, return the given B in right.
    #
    # @param [Object] lvalue The left value to use if the condition satisfies.
    # @param [Object] rvalue The right value to use if the condition does not satisfy.
    # @param [Boolean] condition The condition to test (when no block given).
    # @yield The condition to test (when no condition given).
    #
    # @return A constructed either based on the given condition.
    #
    # @raise [ArgumentError] When both a condition and a block are given.
    def self.iff(lvalue, rvalue, condition = NO_VALUE)
      raise ArgumentError.new('requires either a condition or a block, not both') if condition != NO_VALUE && block_given?
      condition = block_given? ? yield : !! condition
      condition ? left(lvalue) : right(rvalue)
    end

    # Takes an `Either` to its contained value within left or right.
    #
    # @return [Object] Either left or right, whichever is set.
    def reduce
      left? ? left : right
    end

    private

    # @!visibility private 
    def initialize(left, right, projection)
      @is_left = projection
      @left = left
      @right = right
    end
  end
end
