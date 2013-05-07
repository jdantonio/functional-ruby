module PatternMatching

  VERSION = '0.0.1'

  UNBOUND = Unbound = Class.new
  ALL = All = Class.new

  def self.included(base)

    base.instance_variable_set(:@__function_pattern_matches__, Hash.new)

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

    def __pattern_match__(func, *args, &block) # :nodoc:
      clazz = self.class
      args = args.first

      # get the array of matchers for this function
      matchers = clazz.instance_variable_get(:@__function_pattern_matches__)[func]

      # scan through all patterns for this function
      index = matchers.index{|matcher| __match_pattern__(args, matcher.first)}

      if index.nil?
        [:nomatch, nil]
      else
        # if a match is found call the block
        argv = []
        match = matchers[index]
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
        return [:ok, self.instance_exec(*argv, &match.last)]
      end
    end

    class << base

      UNBOUND = PatternMatching::UNBOUND
      ALL = PatternMatching::ALL

      def _() # :nodoc:
        return UNBOUND
      end

      def __add_pattern_for__(func, *args, &block) # :nodoc:
        block = Proc.new{} unless block_given?
        matchers = self.instance_variable_get(:@__function_pattern_matches__)
        matchers[func] = [] unless matchers.has_key?(func)
        matchers[func] << [args, block]
      end

      def defn(func, *args, &block)

        block = Proc.new{} unless block_given?
        __add_pattern_for__(func, *args, &block)

        unless self.instance_methods(false).include?(func)
          self.send(:define_method, func) do |*args, &block|
            result, value = __pattern_match__(func, args, block)
            return value if result == :ok
            begin
              super(*args, &block)
            rescue NoMethodError
              raise NoMethodError.new("no method `#{func}` matching #{args} found for class #{self.class}")
            end
          end
        end
      end

    end
  end
end
