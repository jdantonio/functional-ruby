require_relative 'either'

module Functional

  # As much as I love Ruby I've always been a little disappointed that Ruby doesn't
  # support function overloading. Function overloading tends to reduce branching
  # and keep function signatures simpler. No sweat, I learned to do without. Then
  # I started programming in Erlang. My favorite Erlang feature is, without
  # question, pattern matching. Pattern matching is like function overloading
  # cranked to 11. So one day I was musing on Twitter that I'd like to see
  # Erlang-stype pattern matching in Ruby and one of my friends responded
  # "Build it!" So I did. And here it is.
  #
  # @!macro pattern_matching
  module PatternMatching

    # A parameter that is required but that can take any value.
    # @!visibility private
    UNBOUND = Object.new.freeze

    # A match for one or more parameters in the last position of the match.
    # @!visibility private
    ALL = Object.new.freeze

    private

    # A guard clause on a pattern match.
    # @!visibility private
    GUARD_CLAUSE = Class.new do
      def initialize(func, clazz, matcher)
        @func = func
        @clazz = clazz
        @matcher = matcher
      end
      def when(&block)
        unless block_given?
          raise ArgumentError.new("block missing for `when` guard on function `#{@func}` of class #{@clazz}")
        end
        @matcher[@matcher.length-1] = block
        self
      end
    end

    # @!visibility private
    class SignatureMatcher

      def initialize(pattern, args)
        @pattern = pattern
        @args = args
      end

      def match?
        return false unless valid_pattern?(@args, @pattern)

        @pattern.length.times.all? do |index|
          param = @pattern[index]
          arg = @args[index]

          all_param_and_last_arg?(@pattern, param, index) ||
            arg_is_type_of_param?(param, arg) ||
            hash_param_with_matching_arg?(param, arg) ||
            param_matches_arg?(param, arg)
        end
      end

      private

      def valid_pattern?(args, pattern)
        (pattern.last == ALL && args.length >= pattern.length) \
          || (args.length == pattern.length)
      end

      def all_param_and_last_arg?(pattern, param, index)
        param == ALL && index+1 == pattern.length
      end

      def arg_is_type_of_param?(param, arg)
        param.is_a?(Class) && arg.is_a?(param)
      end

      def hash_param_with_matching_arg?(param, arg)
        param.is_a?(Hash) &&
          arg.is_a?(Hash) &&
          ! param.empty? &&
          param.all? do |key, value|
            arg.has_key?(key) && (value == UNBOUND || arg[key] == value)
          end
      end

      def param_matches_arg?(param, arg)
        param == UNBOUND || param == arg
      end
    end

    # @!visibility private
    def __unbound_args__(match, args)
      argv = []
      match.first.each_with_index do |p, i|
        if p == ALL && i == match.first.length-1
          argv << args[(i..args.length)].reduce([]){|memo, arg| memo << arg }
        elsif p.is_a?(Hash) && p.values.include?(UNBOUND)
          p.each do |key, value|
            argv << args[i][key] if value == UNBOUND
          end
        elsif p.is_a?(Hash) || p == UNBOUND || p.is_a?(Class)
          argv << args[i] 
        end
      end
      argv
    end

    # @!visibility private
    def __pattern_match__(clazz, func, *args, &block)
      args = args.first

      matchers = clazz.__function_pattern_matches__[func]
      return Either.reason(:nodef) if matchers.nil?

      match = matchers.detect do |matcher|
        if SignatureMatcher.new(matcher.first, args).match?
          if matcher.last.nil?
            true # no guard clause
          else
            self.instance_exec(*__unbound_args__(matcher, args), &matcher.last)
          end
        end
      end

      (match ? Either.value(match) : Either.reason(:nomatch))
    end

    def self.included(base)
      base.extend(ClassMethods)
      super(base)
    end

    # Class methods added to a class that includes {Functional::PatternMatching}
    # @!visibility private
    module ClassMethods

      # @!visibility private
      def _()
        UNBOUND
      end

      # @!visibility private
      def defn(func, *args, &block)
        unless block_given?
          raise ArgumentError.new("block missing for definition of function `#{func}` on class #{self}")
        end

        # add a new pattern for this function
        pattern = __add_pattern_for__(func, *args, &block)

        # define the delegator function if it doesn't exist yet
        unless self.instance_methods(false).include?(func)
          __define_method_with_matching__(func)
        end

        # return a guard clause to be added to the pattern
        GUARD_CLAUSE.new(func, self, pattern)
      end

      # @!visibility private
      # define an arity -1 function that dispatches to the appropriate
      # pattern match variant or raises an exception
      def __define_method_with_matching__(func)
        define_method(func) do |*args, &block|
          # get the collection of matched patterns for this function
          # use owner to ensure we look up the inheritance tree
          match = __pattern_match__(self.method(func).owner, func, args, block)
          if match.value?
            # if a match is found call the block
            argv = __unbound_args__(match.value, args)
            return self.instance_exec(*argv, &match.value[1])
          else # if result == :nodef || result == :nomatch
            begin
              # delegate to the superclass
              super(*args, &block)
            rescue NoMethodError, ArgumentError
              # raise a custom error
              raise NoMethodError.new("no method `#{func}` matching #{args} found for class #{self.class}")
            end
          end
        end
      end

      # @!visibility private
      def __function_pattern_matches__
        @__function_pattern_matches__ ||= Hash.new
      end

      # @!visibility private
      def __add_pattern_for__(func, *args, &block)
        # create an empty proc if no function body is given
        block = Proc.new{} unless block_given?
        # retrieve the list of patterns for this function from the class cache
        matchers = self.__function_pattern_matches__
        # add a new pattern collection when a new function is given
        matchers[func] = [] unless matchers.has_key?(func)
        # store the new pattern in the collection
        # the last element of the array is the guard clause
        matchers[func] << [args, block, nil]
        # why are we returning nil?
        matchers[func].last
      end
    end
  end
end
