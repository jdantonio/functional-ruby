module PatternMatching

  VERSION = '0.0.1'

  def self.included(base)

    base.instance_variable_set(:@__function_pattern_matches__, Hash.new)

    def __pattern_match__(func, *args, &block)
      clazz = self.class

      matchers = clazz.instance_variable_get(:@__function_pattern_matches__)
      matchers = matchers[func]

      # scan through all patterns for this function
      match = nil
      matchers.each do |matcher|
        if args.first == matcher.first
          match = matcher.last
          break(matcher.last)
        end
      end

      # if a match is found call the block
      if match.nil?
        [:nomatch, nil]
      else
        return [:ok, match.call(*args.first)]
      end
    end

    class << base

      def __add_pattern_for(func, *args, &block)
        block = Proc.new{} unless block_given?
        matchers = self.instance_variable_get(:@__function_pattern_matches__)
        matchers[func] = [] unless matchers.has_key?(func)
        matchers[func] << [args, block]
      end

      def defn(func, *args, &block)

        block = Proc.new{} unless block_given?
        __add_pattern_for(func, *args, &block)

        unless self.instance_methods(false).include?(func)
          self.send(:define_method, func) do |*args, &block|
            result, value = __pattern_match__(func, args, block)
            return value if result == :ok
            begin
              super(*args, &block)
            rescue NoMethodError
              raise NoMethodError.new("no method `#{func}` matching `#{args}` found for #{self.class}")
            end
          end
        end
      end

    end
  end
end
