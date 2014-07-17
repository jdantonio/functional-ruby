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
      def method(name, arity = Functional::BehaviorCheck::ANY_ARITY)
        arity = arity.to_i unless arity == Functional::BehaviorCheck::ANY_ARITY
        @info[:methods][name.to_sym] = arity
      end
      def class_method(name, arity = Functional::BehaviorCheck::ANY_ARITY)
        arity = arity.to_i unless arity == Functional::BehaviorCheck::ANY_ARITY
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

  def BehaveAs?(behavior, *behaviors)
  end
  alias_method :BehavesAs?, :BehaveAs?
  module_function :BehaveAs?

  def BehaveAs!(behavior, *behaviors)
  end
  alias_method :BehavesAs!, :BehaveAs!
  module_function :BehaveAs!

  def BehaviorDefined?(*behaviors)
  end
  module_function :BehaviorDefined?

  def BehaviorDefined!(*behaviors)
  end
  module_function :BehaviorDefined!

  module BehaviorCheck

    @@info = {}

    ANY_ARITY = BasicObject.new

    def BehaveAs?(target, *behaviors)
    end
    alias_method :BehavesAs?, :BehaveAs?

    def BehaveAs!(target, *behaviors)
    end
    alias_method :BehavesAs!, :BehaveAs!

    def BehaviorDefined?(*behaviors)
    end

    def BehaviorDefined!(*behaviors)
    end
  end
end
