require 'functional/synchronization'

module Functional

  # Memoization is a technique for optimizing functions that are time-consuming
  # and/or involve expensive calculations. Every time a memoized function is
  # called the result is caches with reference to the given parameters.
  # Subsequent calls to the function that use the same parameters will return
  # the cached result. As a result the response time for frequently called
  # functions is vastly increased (after the first call with any given set of)
  # arguments, at the cost of increased memory usage (the cache).
  #
  # {include:file:doc/memo.md}
  #
  # @note Memoized method calls are thread safe and can safely be used in
  #   concurrent systems. Declaring memoization on a function is *not* thread
  #   safe and should only be done during application initialization.
  module Memo

    # @!visibility private
    def self.extended(base)
      base.extend(ClassMethods)
      base.send(:__method_memos__=, {})
      super(base)
    end

    # @!visibility private
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:__method_memos__=, {})
      super(base)
    end

    # @!visibility private
    module ClassMethods

      # @!visibility private
      class Memoizer < Synchronization::Object
        attr_reader :function, :cache, :max_cache
        def initialize(function, max_cache)
          super
          synchronize do
            @function = function
            @max_cache = max_cache
            @cache = {}
          end
        end
        def max_cache?
          max_cache > 0 && cache.size >= max_cache
        end
        public :synchronize
      end
      private_constant :Memoizer

      # @!visibility private
      attr_accessor :__method_memos__

      # Returns a memoized version of a referentially transparent function. The
      # memoized version of the function keeps a cache of the mapping from
      # arguments to results and, when calls with the same arguments are
      # repeated often, has higher performance at the expense of higher memory
      # use.
      #
      # @param [Symbol] func the class/module function to memoize
      # @param [Hash] opts the options controlling memoization
      # @option opts [Fixnum] :at_most the maximum number of memos to store in
      #   the cache; a value of zero (the default) or `nil` indicates no limit
      #
      # @raise [ArgumentError] when the method has already been memoized
      # @raise [ArgumentError] when :at_most option is a negative number
      def memoize(func, opts = {})
        func = func.to_sym
        max_cache = opts[:at_most].to_i
        raise ArgumentError.new("method :#{func} has already been memoized") if __method_memos__.has_key?(func)
        raise ArgumentError.new(':max_cache must be > 0') if max_cache < 0
        __method_memos__[func] = Memoizer.new(method(func), max_cache.to_i)
        __define_memo_proxy__(func)
        nil
      end

      # @!visibility private
      def __define_memo_proxy__(func)
        self.class_eval <<-RUBY
          def self.#{func}(*args, &block)
            self.__proxy_memoized_method__(:#{func}, *args, &block)
          end
        RUBY
      end

      # @!visibility private
      def __proxy_memoized_method__(func, *args, &block)
        memo = self.__method_memos__[func]
        memo.synchronize do
          if block_given?
            memo.function.call(*args, &block)
          elsif memo.cache.has_key?(args)
            memo.cache[args]
          else
            result = memo.function.call(*args)
            memo.cache[args] = result unless memo.max_cache?
          end
        end
      end
    end
  end
end
