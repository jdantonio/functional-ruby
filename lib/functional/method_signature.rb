module Functional

  module PatternMatching

    # @!visibility private
    module MethodSignature
      extend self

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

      def valid_pattern?(args, pattern)
        (pattern.last == PatternMatching::ALL && args.length >= pattern.length) \
          || (args.length == pattern.length)
      end

      def all_param_and_last_arg?(pattern, param, index)
        param == PatternMatching::ALL && index+1 == pattern.length
      end

      def arg_is_type_of_param?(param, arg)
        param.is_a?(Class) && arg.is_a?(param)
      end

      def hash_param_with_matching_arg?(param, arg)
        param.is_a?(Hash) && arg.is_a?(Hash) && ! param.empty? && param.all? do |key, value|
          arg.has_key?(key) && (value == PatternMatching::UNBOUND || arg[key] == value)
        end
      end

      def param_matches_arg?(param, arg)
        param == PatternMatching::UNBOUND || param == arg
      end
    end
  end
end
