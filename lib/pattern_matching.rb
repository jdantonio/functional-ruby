require 'pp'

module PatternMatching

  VERSION = '0.2.0'

  UNBOUND = Class.new
  ALL = Class.new

  def self.included(base)
    
    protected

    def base.__function_pattern_matches__
      @__function_pattern_matches__ ||= Hash.new
    end

    private

    def __match_pattern__(args, pattern) # :nodoc:
      return unless (pattern.last == ALL && args.length >= pattern.length) \
        || (args.length == pattern.length)
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

    def __unbound_args__(match, args) # :nodoc:
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

    def __pattern_match__(func, *args, &block) # :nodoc:
      clazz = self.class
      args = args.first

      # get the array of matchers for this function
      matchers = clazz.__function_pattern_matches__[func]
      

      # NOTE: Not the intended behavior
      # Pattern matches in superclasses override concrete
      # functions defined below them in the hierarchy
      #return [:nomatch, nil] if matchers.nil?
      
      # if function is not found, climb the superclass tree
      if matchers.nil? 
        clazz.ancestors.each do |parent|
          matchers = parent.__function_pattern_matches__[func]
          break unless matchers.nil?
        end
      end

      # scan through all patterns for this function
      index = matchers.index do |matcher|
        if __match_pattern__(args, matcher.first)
          if matcher.last.nil?
            true # no guard clause
          else
            self.instance_exec(*__unbound_args__(matcher, args), &matcher.last)
          end
        end
      end

      if index.nil?
        return [:nomatch, nil]
      else
        # if a match is found call the block
        match = matchers[index]
        argv = __unbound_args__(match, args)
        return [:ok, self.instance_exec(*argv, &match[1])]
      end
    end

    class << base

      public

      def _() # :nodoc:
        return UNBOUND
      end

      def defn(func, *args, &block)

        guard = Class.new do
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

        block = Proc.new{} unless block_given?
        pattern = __add_pattern_for__(func, *args, &block)

        unless self.instance_methods(false).include?(func)
          self.send(:define_method, func) do |*args, &block|
            result, value = __pattern_match__(func, args, block)
            return value if result == :ok
            begin
              super(*args, &block)
            rescue NoMethodError, ArgumentError
              raise NoMethodError.new("no method `#{func}` matching #{args} found for class #{self.class}")
            end
          end
        end

        return guard.new(func, self, pattern)
      end

      private

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
