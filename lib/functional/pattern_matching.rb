require_relative 'type_check'

module Functional

  # {include:file:doc/pattern_matching.md}
  module PatternMatching
    extend TypeCheck

    UNBOUND = Object.new
    ALL = Object.new

    private

    GUARD_CLAUSE = Class.new do # :nodoc:
      def initialize(func, clazz, matcher) # :nodoc:
        @func = func
        @clazz = clazz
        @matcher = matcher
      end
      def when(&block) # :nodoc:
        unless block_given?
          raise ArgumentError.new("block missing for `when` guard on function `#{@func}` of class #{@clazz}")
        end
        @matcher[@matcher.length-1] = block
        return nil
      end
    end

    def self.__match_pattern__(args, pattern) # :nodoc:
      return unless (pattern.last == ALL && args.length >= pattern.length) \
        || (args.length == pattern.length)
      pattern.each_with_index do |p, i|
        break if p == ALL && i+1 == pattern.length
        arg = args[i]
        next if Type?(p, Class) && Type?(arg, p)
        if Type?(p, Hash) && Type?(arg, Hash) && ! p.empty?
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

    def self.__unbound_args__(match, args) # :nodoc:
      argv = []
      match.first.each_with_index do |p, i|
        if p == ALL && i == match.first.length-1
          argv << args[(i..args.length)].reduce([]){|memo, arg| memo << arg }
        elsif Type?(p, Hash) && p.values.include?(UNBOUND)
          p.each do |key, value|
            argv << args[i][key] if value == UNBOUND
          end
        elsif Type?(p, Hash) || p == UNBOUND || Type?(p, Class)
          argv << args[i] 
        end
      end
      return argv
    end

    def self.__pattern_match__(clazz, func, *args, &block) # :nodoc:
      args = args.first

      matchers = clazz.__function_pattern_matches__[func]
      return [:nodef, nil] if matchers.nil?

      match = matchers.detect do |matcher|
        if PatternMatching.__match_pattern__(args, matcher.first)
          if matcher.last.nil?
            true # no guard clause
          else
            self.instance_exec(*PatternMatching.__unbound_args__(matcher, args), &matcher.last)
          end
        end
      end

      return (match ? [:ok, match] : [:nomatch, nil])
    end

    protected

    def self.included(base)

      class << base

        public

        def _() # :nodoc:
          return UNBOUND
        end

        def defn(func, *args, &block)
          unless block_given?
            raise ArgumentError.new("block missing for definition of function `#{func}` on class #{self}")
          end

          pattern = __add_pattern_for__(func, *args, &block)

          unless self.instance_methods(false).include?(func)

            define_method(func) do |*args, &block|
              result, match = PatternMatching.__pattern_match__(self.method(func).owner, func, args, block)
              if result == :ok
                # if a match is found call the block
                argv = PatternMatching.__unbound_args__(match, args)
                return self.instance_exec(*argv, &match[1])
              else # if result == :nodef || result == :nomatch
                begin
                  super(*args, &block)
                rescue NoMethodError, ArgumentError
                  raise NoMethodError.new("no method `#{func}` matching #{args} found for class #{self.class}")
                end
              end
            end
          end

          return GUARD_CLAUSE.new(func, self, pattern)
        end

        public

        def __function_pattern_matches__ # :nodoc:
          @__function_pattern_matches__ ||= Hash.new
        end

        def __add_pattern_for__(func, *args, &block) # :nodoc:
          block = Proc.new{} unless block_given?
          matchers = self.__function_pattern_matches__
          matchers[func] = [] unless matchers.has_key?(func)
          matchers[func] << [args, block, nil]
          return matchers[func].last
        end
      end
    end
  end
end
