module Functional

  BehaviorError = Class.new(StandardError)

  def BehaviorInfo(behavior, &block)
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
  module_function :BehaviorInfo

  def Behavior(behavior)
  end
  module_function :Behavior

  module BehaviorCheck

    @@info = {}

    def BehaveAs?(target, *behaviors)
      results = behaviors.drop_while do |behavior|
        behave_as?(target, behavior.to_sym)
      end
      results.empty?
    end
    alias_method :BehavesAs?, :BehaveAs?
    module_function :BehaveAs?
    module_function :BehavesAs?

    def BehaveAs!(target, *behaviors)
    end
    alias_method :BehavesAs!, :BehaveAs!
    module_function :BehaveAs!
    module_function :BehavesAs!

    def BehaviorDefined?(*behaviors)
    end
    module_function :BehaviorDefined?

    def BehaviorDefined!(*behaviors)
    end
    module_function :BehaviorDefined!

    private

    def self.check_arity?(target, method, arity)
      expected = target.method(method).arity
      arity.nil? || arity == expected
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
  end
end
