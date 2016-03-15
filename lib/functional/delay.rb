require 'functional/synchronization'

module Functional

  # Lazy evaluation of a block yielding an immutable result. Useful for
  # expensive operations that may never be needed.
  #
  # When a `Delay` is created its state is set to `pending`. The value and
  # reason are both `nil`. The first time the `#value` method is called the
  # enclosed opration will be run and the calling thread will block. Other
  # threads attempting to call `#value` will block as well. Once the operation
  # is complete the *value* will be set to the result of the operation or the
  # *reason* will be set to the raised exception, as appropriate. All threads
  # blocked on `#value` will return. Subsequent calls to `#value` will
  # immediately return the cached value. The operation will only be run once.
  # This means that any side effects created by the operation will only happen
  # once as well.
  #
  # @!macro [new] thread_safe_immutable_object
  #
  #    @note This is a write-once, read-many, thread safe object that can be
  #      used in concurrent systems. Thread safety guarantees *cannot* be made
  #      about objects contained *within* this object, however. Ruby variables
  #      are mutable references to mutable objects. This cannot be changed. The
  #      best practice it to only encapsulate immutable, frozen, or thread safe
  #      objects. Ultimately, thread safety is the responsibility of the
  #      programmer.
  #
  # @see http://clojuredocs.org/clojure_core/clojure.core/delay Clojure delay
  class Delay < Synchronization::Object

    # Create a new `Delay` in the `:pending` state.
    #
    # @yield the delayed operation to perform
    #
    # @raise [ArgumentError] if no block is given
    def initialize(&block)
      raise ArgumentError.new('no block given') unless block_given?
      super
      synchronize do
        @state = :pending
        @task  = block
      end
    end

    # Current state of block processing.
    #
    # @return [Symbol] the current state of block processing
    def state
      synchronize{ @state }
    end

    # The exception raised when processing the block. Returns `nil` if the
    # operation is still `:pending` or has been `:fulfilled`.
    #
    # @return [StandardError] the exception raised when processing the block
    #   else nil.
    def reason
      synchronize{ @reason }
    end

    # Return the (possibly memoized) value of the delayed operation.
    #
    # If the state is `:pending` then the calling thread will block while the
    # operation is performed. All other threads simultaneously calling `#value`
    # will block as well. Once the operation is complete (either `:fulfilled` or
    # `:rejected`) all waiting threads will unblock and the new value will be
    # returned.
    #
    # If the state is not `:pending` when `#value` is called the (possibly
    # memoized) value will be returned without blocking and without performing
    # the operation again.
    #
    # @return [Object] the (possibly memoized) result of the block operation
    def value
      synchronize{ execute_task_once }
    end

    # Has the delay been fulfilled?
    # @return [Boolean]
    def fulfilled?
      synchronize{ @state == :fulfilled }
    end
    alias_method :value?, :fulfilled?

    # Has the delay been rejected?
    # @return [Boolean]
    def rejected?
      synchronize{ @state == :rejected }
    end
    alias_method :reason?, :rejected?

    # Is delay completion still pending?
    # @return [Boolean]
    def pending?
      synchronize{ @state == :pending }
    end

    protected

    # @!visibility private
    #
    # Execute the enclosed task then cache and return the result if the current
    # state is pending. Otherwise, return the cached result.
    #
    # @return [Object] the result of the block operation
    def execute_task_once
      if @state == :pending
        begin
          @value = @task.call
          @state = :fulfilled
        rescue => ex
          @reason = ex
          @state  = :rejected
        end
      end
      @value
    end
  end
end
