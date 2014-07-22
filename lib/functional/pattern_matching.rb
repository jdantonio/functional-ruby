require_relative 'either'

module Functional

  # {include:file:doc/pattern_matching.md}
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
    GUARD_CLAUSE = Class.new do # :nodoc:
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
        return nil
      end
    end

    # @!visibility private
    def self.match_pattern(args, pattern) # :nodoc:
      return unless valid_pattern?(args, pattern)
      pattern.each_with_index do |p, i|
        break if p == ALL && i+1 == pattern.length
        arg = args[i]
        next if p.is_a?(Class) && arg.is_a?(p)
        if p.is_a?(Hash) && arg.is_a?(Hash) && ! p.empty?
          p.each do |key, value|
            return false unless arg.has_key?(key)
            next if value == UNBOUND
            return false unless arg[key] == value
          end
          next
        end
        return false unless p == UNBOUND || p == arg
      end
      return true
    end

    # @!visibility private
    def self.valid_pattern?(args, pattern) # :nodoc:
      (pattern.last == ALL && args.length >= pattern.length) \
        || (args.length == pattern.length)
    end

    # @!visibility private
    def self.unbound_args(match, args) # :nodoc:
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
      return argv
    end

    # @!visibility private
    def self.pattern_match(clazz, func, *args, &block) # :nodoc:
      args = args.first

      matchers = clazz.function_pattern_matches[func]
      return Either.reason(:nodef) if matchers.nil?

      match = matchers.detect do |matcher|
        if PatternMatching.match_pattern(args, matcher.first)
          if matcher.last.nil?
            true # no guard clause
          else
            self.instance_exec(*PatternMatching.unbound_args(matcher, args), &matcher.last)
          end
        end
      end

      return (match ? Either.value(match) : Either.reason(:nomatch))
    end

    def self.included(base)
      base.extend(ClassMethods)
      super(base)
    end

    # Class methods added to a class that includes {Functional::PatternMatching}
    # @!visibility private
    module ClassMethods

      # @!visibility private
      def _() # :nodoc:
        return UNBOUND
      end

      # @!visibility private
      def defn(func, *args, &block) # :nodoc:
        unless block_given?
          raise ArgumentError.new("block missing for definition of function `#{func}` on class #{self}")
        end

        pattern = add_pattern_for(func, *args, &block)

        unless self.instance_methods(false).include?(func)
          define_method_with_matching(func)
        end

        return GUARD_CLAUSE.new(func, self, pattern)
      end

      # @!visibility private
      def define_method_with_matching(func) # :nodoc:
        define_method(func) do |*args, &block|
          match = PatternMatching.pattern_match(self.method(func).owner, func, args, block)
          if match.value?
            # if a match is found call the block
            argv = PatternMatching.unbound_args(match.value, args)
            return self.instance_exec(*argv, &match.value[1])
          else # if result == :nodef || result == :nomatch
            begin
              super(*args, &block)
            rescue NoMethodError, ArgumentError
              raise NoMethodError.new("no method `#{func}` matching #{args} found for class #{self.class}")
            end
          end
        end
      end

      # @!visibility private
      def function_pattern_matches # :nodoc:
        @function_pattern_matches ||= Hash.new
      end

      # @!visibility private
      def add_pattern_for(func, *args, &block) # :nodoc:
        block = Proc.new{} unless block_given?
        matchers = self.function_pattern_matches
        matchers[func] = [] unless matchers.has_key?(func)
        matchers[func] << [args, block, nil]
        return matchers[func].last
      end
    end
  end
end
