require_relative 'abstract_struct'
require_relative 'protocol'

Functional::SpecifyProtocol(:Either) do
  instance_method :left, 0
  instance_method :left?, 0
  instance_method :right, 0
  instance_method :right?, 0
end

Functional::SpecifyProtocol(:Disposition) do
  instance_method :value, 0
  instance_method :value?, 0
  instance_method :reason, 0
  instance_method :reason?, 0
  instance_method :fulfilled?, 0
  instance_method :rejected?, 0
end

module Functional

  # The `Either` type represents a value of one of two possible types (a disjoint union).
  # It is an immutable structure that contains one and only one value. That value can
  # be stored in one of two virtual position, `left` or `right`. The position provides
  # context for the encapsulated data.
  #
  # One of the main uses of `Either` is as a return value that can indicate either
  # success or failure. Object oriented programs generally report errors through
  # either state or exception handling, neither of which work well in functional
  # programming. In the former case, a method is called on an object and when an
  # error occurs the state of the object is updated to reflect the error. This does
  # not translate well to functional programming because they eschew state and
  # mutable objects. In the latter, an exception handling block provides branching
  # logic when an exception is thrown. This does not translate well to functional
  # programming because it eschews side effects like structured exception handling
  # (and structured exception handling tends to be very expensive). `Either` provides
  # a powerful and easy-to-use alternative.
  #
  # A function that may generate an error can choose to return an immutable `Either`
  # object in which the position of the value (left or right) indicates the nature
  # of the data. By convention, a `left` value indicates an error and a `right` value
  # indicates success. This leaves the caller with no ambiguity regarding success or
  # failure, requires no persistent state, and does not require expensive exception
  # handling facilities.
  #
  # `Either` provides several aliases and convenience functions to facilitate these
  # failure/success conventions. The `left` and `right` functions, including their
  # derivatives, are mirrored by `reason` and `value`. Failure is indicated by the
  # presence of a `reason` and success is indicated by the presence of a `value`.
  # When an operation has failed the either is in a `rejected` state, and when an
  # operation has successed the either is in a `fulfilled` state. A common convention
  # is to use a Ruby `Exception` as the `reason`. The factory method `error` facilitates
  # this. The semantics and conventions of `reason`, `value`, and their derivatives
  # follow the conventions of the Concurrent Ruby gem.
  #
  # The `left`/`right` and `reason`/`value` methods are not mutually exclusive. They
  # can be commingled and still result in functionally correct code. This practice
  # should be avoided, however. Consistent use of either `left`/`right` or
  # `reason`/`value` against each `Either` instance will result in more expressive,
  # intent-revealing code.
  #
  # @example
  #
  #   require 'uri'
  #
  #   def web_host(url)
  #     uri = URI(url)
  #     if uri.scheme == 'http'
  #       Functional::Either.left(uri.host)
  #     else
  #       Functional::Either.right('Invalid HTTP URL')
  #     end
  #   end
  #
  #   good = web_host('http://www.concurrent-ruby.com')
  #   good.left? #=> true
  #   good.left  #=> "www.concurrent-ruby"
  #   good.right #=> nil
  #
  #   good = web_host('bogus')
  #   good.left? #=> false
  #   good.left  #=> nil
  #   good.right #=> "Invalid HTTP URL"
  #
  # @see http://functionaljava.googlecode.com/svn/artifacts/3.0/javadoc/fj/data/Either.html Functional Java
  # @see http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Obligation.html Concurrent Ruby
  class Either
    include AbstractStruct

    self.datatype = :either
    self.fields = [:left, :right].freeze

    # @!visibility private 
    NO_VALUE = Object.new.freeze

    private_class_method :new

    class << self

      # Construct a left value of either.
      #
      # @param [Object] value The value underlying the either.
      # @return [Either] A new either with the given left value.
      def left(value)
        new(value, true).freeze
      end
      alias_method :reason, :left

      # Construct a right value of either.
      #
      # @param [Object] value The value underlying the either.
      # @return [Either] A new either with the given right value.
      def right(value)
        new(value, false).freeze
      end
      alias_method :value, :right

      # Create an `Either` with the left value set to an `Exception` object
      # complete with message and backtrace. This is a convenience method for
      # supporting the reason/value convention with the reason always being
      # an `Exception` object. When no exception class is given `StandardError`
      # will be used. When no message is given the default message for the
      # given error class will be used.
      #
      # @example
      # 
      #   either = Functional::Either.error("You're a bad monkey, Mojo Jojo")
      #   either.fulfilled? #=> false
      #   either.rejected?  #=> true
      #   either.value      #=> nil
      #   either.reason     #=> #<StandardError: You're a bad monkey, Mojo Jojo>
      #
      # @param [String] message The message for the new error object.
      # @param [Exception] clazz The class for the new error object.
      # @return [Either] A new either with an error object as the left value.
      def error(message = nil, clazz = StandardError)
        ex = clazz.new(message)
        ex.set_backtrace(caller)
        left(ex)
      end
    end

    # Projects this either as a left.
    # 
    # @return [Object] The left value or `nil` when `right`.
    def left
      left? ? to_h[:left] : nil
    end
    alias_method :reason, :left

    # Projects this either as a right.
    # 
    # @return [Object] The right value or `nil` when `left`.
    def right
      right? ? to_h[:right] : nil
    end
    alias_method :value, :right

    # Returns true if this either is a left, false otherwise.
    #
    # @return [Boolean] `true` if this either is a left, `false` otherwise.
    def left?
      @is_left
    end
    alias_method :reason?, :left?
    alias_method :rejected?, :left?

    # Returns true if this either is a right, false otherwise.
    #
    # @return [Boolean] `true` if this either is a right, `false` otherwise.
    def right?
      ! left?
    end
    alias_method :value?, :right?
    alias_method :fulfilled?, :right?

    # If this is a left, then return the left value in right, or vice versa.
    #
    # @return [Either] The value of this either swapped to the opposing side.
    def swap
      if left?
        self.class.send(:new, left, false)
      else
        self.class.send(:new, right, true)
      end
    end

    # The catamorphism for either. Folds over this either breaking into left or right.
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
    # @return [Either] A constructed either based on the given condition.
    #
    # @raise [ArgumentError] When both a condition and a block are given.
    def self.iff(lvalue, rvalue, condition = NO_VALUE)
      raise ArgumentError.new('requires either a condition or a block, not both') if condition != NO_VALUE && block_given?
      condition = block_given? ? yield : !! condition
      condition ? left(lvalue) : right(rvalue)
    end

    private

    # Create a new Either wil the given value and disposition.
    #
    # @param [Object] value the value of this either
    # @param [Boolean] is_left is this a left either or right?
    #
    # @!visibility private 
    def initialize(value, is_left)
      @is_left = is_left
      hsh = is_left ? {left: value, right: nil} : {left: nil, right: value}
      set_data_hash(hsh)
      set_values_array(hsh.values)
    end
  end
end
