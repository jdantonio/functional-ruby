module Functional

  module PatternMatching

    # @!visibility private
    #
    # Helper functions used when pattern matching runtime arguments against
    # a method defined with the `defn` function of Functional::PatternMatching.
    module MethodSignature
      extend self

      # Do the given arguments match the given function pattern?
      #
      # @return [Boolean] true when there is a match else false
      def match?(pattern, args)
        return false unless valid_pattern?(args, pattern)

        pattern.length.times.all? do |index|
          param = pattern[index]
          arg = args[index]

          all_param_and_last_arg?(pattern, param, index) ||
            arg_is_type_of_param?(param, arg) ||
            hash_param_with_matching_arg?(param, arg) ||
            param_matches_arg?(param, arg)
        end
      end

      # Is the given pattern a valid pattern with respect to the given
      # runtime arguments?
      #
      # @return [Boolean] true when the pattern is valid else false
      def valid_pattern?(args, pattern)
        (pattern.last == PatternMatching::ALL && args.length >= pattern.length) \
          || (args.length == pattern.length)
      end

      # Is this the last parameter and is it `ALL`?
      #
      # @return [Boolean] true when matching else false
      def all_param_and_last_arg?(pattern, param, index)
        param == PatternMatching::ALL && index+1 == pattern.length
      end

      # Is the parameter a class and is the provided argument an instance
      # of that class?
      #
      # @return [Boolean] true when matching else false
      def arg_is_type_of_param?(param, arg)
        param.is_a?(Class) && arg.is_a?(param)
      end

      # Is the given parameter a Hash and does it match the given
      # runtime argument?
      #
      # @return [Boolean] true when matching else false
      def hash_param_with_matching_arg?(param, arg)
        param.is_a?(Hash) && arg.is_a?(Hash) && ! param.empty? && param.all? do |key, value|
          arg.has_key?(key) && (value == PatternMatching::UNBOUND || arg[key] == value)
        end
      end

      # Does the given parameter exactly match the given runtime
      # argument or is the parameter `UNBOUND`?
      #
      # @return [Boolean] true when matching else false
      def param_matches_arg?(param, arg)
        param == PatternMatching::UNBOUND || param == arg
      end
    end
    private_constant :MethodSignature
  end
end
