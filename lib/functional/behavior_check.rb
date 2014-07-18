module Functional

  BehaviorError = Class.new(StandardError)

  def DefineBehavior(behavior, &block)
    behavior = behavior.to_sym
    behavior_info = BehaviorCheck.class_variable_get(:@@info)[behavior]

    return behavior_info unless block_given?

    if block_given? && ! behavior_info.nil?
      raise BehaviorError.new(":#{behavior} has already been defined")
    end

    info = {
      methods: {},
      class_methods: {}
    }

    proxy = Class.new do
      def initialize(info)
        @info = info
      end
      def method(name, arity = nil)
        arity = arity.to_i unless arity.nil?
        @info[:methods][name.to_sym] = arity
      end
      def class_method(name, arity = nil)
        arity = arity.to_i unless arity.nil?
        @info[:class_methods][name.to_sym] = arity
      end
    end

    proxy.new(info).instance_eval(&block)
    BehaviorCheck.class_variable_get(:@@info)[behavior] = info
  end
  module_function :DefineBehavior

  module BehaviorCheck

    @@info = {}

    def Behave?(target, *behaviors)
      behaviors.drop_while { |behavior|
        BehaviorCheck.behave_as?(target, behavior.to_sym)
      }.empty?
    end

    def Behave!(target, *behaviors)
      Behave?(target, *behaviors) or
        BehaviorCheck.error(target, 'does not', behaviors)
      target
    end

    def Behavior?(*behaviors)
      BehaviorCheck.undefined(*behaviors).empty?
    end

    def Behavior!(*behaviors)
      (undefined = BehaviorCheck.undefined(*behaviors)).empty? or
        raise BehaviorError.new("The following behaviors are undefined: :#{undefined.join('; :')}.")
    end

    private

    def self.check_arity?(target, method, expected)
      arity = target.method(method).arity
      expected.nil? || arity == -1 || expected == arity
    rescue
      return false
    end

    def self.behave_as?(target, behavior)
      clazz = target.is_a?(Module) ? target : target.class
      info = @@info[behavior]
      return false if info.nil?

      results = info[:methods].drop_while do |method, arity|
        check_arity?(target, method, arity)
      end
      return false unless results.empty?

      results = info[:class_methods].drop_while do |method, arity|
        check_arity?(clazz, method, arity)
      end

      results.empty?
    end

    def self.undefined(*behaviors)
      behaviors.drop_while do |behavior|
        @@info.has_key? behavior.to_sym
      end
    end

    def self.error(target, message, behaviors)
      target = target.class unless target.is_a?(Module)
      raise BehaviorError,
        "Value (#{target.class}) '#{target}' #{message} behave as all of: :#{behaviors.join('; :')}."
      target
    end
  end
end
