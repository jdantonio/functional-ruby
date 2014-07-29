require 'thread'

module Functional

  # @see http://en.wikipedia.org/wiki/Memoization Memoization (Wikipedia)
  # @see http://clojuredocs.org/clojure_core/clojure.core/memoize Clojure memoize
  module Memo

    def self.extended(base)
      base.extend(ClassMethods)
      base.send(:__method_memos__=, {})
      super(base)
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:__method_memos__=, {})
      super(base)
    end

    # @!visibility private
    module ClassMethods

      # @!visibility private
      Memo = Struct.new(:function, :mutex, :cache, :max_cache) do
        def max_cache?
          max_cache > 0 && cache.size >= max_cache
        end
      end

      # @!visibility private
      attr_accessor :__method_memos__

      def memoize(func, opts = {})
        func = func.to_sym
        max_cache = opts[:at_most].to_i
        raise ArgumentError.new("method :#{func} has already been memoized") if __method_memos__.has_key?(func)
        raise ArgumentError.new(':max_cache must be > 0') if max_cache < 0
        __method_memos__[func] = Memo.new(method(func), Mutex.new, {}, max_cache.to_i)
        __define_memo_proxy__(func)
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
        memo.mutex.lock
        if block_given?
          memo.function.call(*args, &block)
        elsif memo.cache.has_key?(args)
          memo.cache[args]
        else
          result = memo.function.call(*args)
          memo.cache[args] = result unless memo.max_cache?
        end
      ensure
        memo.mutex.unlock
      end
    end
  end
end
