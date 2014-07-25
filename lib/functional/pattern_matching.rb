require_relative 'method_signature'

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
    GuardClause = Class.new do
      def initialize(function, clazz, pattern)
        @function = function
        @clazz = clazz
        @pattern = pattern
      end
      def when(&block)
        unless block_given?
          raise ArgumentError.new("block missing for `when` guard on function `#{@function}` of class #{@clazz}")
        end
        @pattern.guard = block
        self
      end
    end

    # @!visibility private
    FunctionPattern = Struct.new(:function, :args, :body, :guard)

    # @!visibility private
    def __unbound_args__(match, args)
      argv = []
      match.args.each_with_index do |p, i|
        if p == ALL && i == match.args.length-1
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

    def __pass_guard__?(matcher, args)
      matcher.guard.nil? ||
        self.instance_exec(*__unbound_args__(matcher, args), &matcher.guard)
    end

    # @!visibility private
    def __pattern_match__(clazz, function, *args, &block)
      args = args.first
      matchers = clazz.__function_pattern_matches__.fetch(function, [])
      matchers.detect do |matcher|
        MethodSignature.match?(matcher.args, args) && __pass_guard__?(matcher, args)
      end
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
      def defn(function, *args, &block)
        unless block_given?
          raise ArgumentError.new("block missing for definition of function `#{function}` on class #{self}")
        end

        # add a new pattern for this function
        pattern = __register_pattern__(function, *args, &block)

        # define the delegator function if it doesn't exist yet
        unless self.instance_methods(false).include?(function)
          __define_method_with_matching__(function)
        end

        # return a guard clause to be added to the pattern
        GuardClause.new(function, self, pattern)
      end

      # @!visibility private
      # define an arity -1 function that dispatches to the appropriate
      # pattern match variant or raises an exception
      def __define_method_with_matching__(function)
        define_method(function) do |*args, &block|
          begin
            # get the collection of matched patterns for this function
            # use owner to ensure we climb the inheritance tree
            match = __pattern_match__(self.method(function).owner, function, args, block)
            if match
              # call the matched function
              argv = __unbound_args__(match, args)
              self.instance_exec(*argv, &match.body)
            else
              # delegate to the superclass
              super(*args, &block)
            end
          rescue NoMethodError, ArgumentError
            # raise a custom error
            raise NoMethodError.new("no method `#{function}` matching #{args} found for class #{self.class}")
          end
        end
      end

      # @!visibility private
      def __function_pattern_matches__
        @__function_pattern_matches__ ||= Hash.new
      end

      # @!visibility private
      def __register_pattern__(function, *args, &block)
        block = Proc.new{} unless block_given?
        pattern = FunctionPattern.new(function, args, block)
        patterns = self.__function_pattern_matches__.fetch(function, [])
        patterns << pattern
        self.__function_pattern_matches__[function] = patterns
        pattern
      end
    end
  end
end
