module PatternMatching

  VERSION = '0.0.1'

  UNBOUND = Unbound = Class.new

  def self.included(base)

    base.instance_variable_set(:@__function_pattern_matches__, Hash.new)

    def __match_pattern__(args, pattern) # :nodoc:
      return unless args.length == pattern.length
      pattern.each_with_index do |p, i|
        arg = args[i]
        if p.is_a?(Hash) && arg.is_a?(Hash)
          next if p.empty?
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

      matchers = clazz.instance_variable_get(:@__function_pattern_matches__)
      matchers = matchers[func]

      # scan through all patterns for this function
      match = nil
      matchers.each do |matcher|
        if __match_pattern__(args.first, matcher.first)
          match = matcher
          break(matcher)
        end
      end

      # if a match is found call the block
      if match.nil?
        [:nomatch, nil]
      else
        argv = []
        match.first.each_with_index do |p, i|
          argv << args.first[i] if p == UNBOUND || p.is_a?(Hash)
        end
        return [:ok, match.last.call(*argv)]
      end
    end

    class << base

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
