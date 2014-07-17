module Functional

  BehaviorError = Class.new(StandardError)

  def BehaviorInfo(behavior, &block)
    return unless block_given?

    temp_proxy = Class.new do
      def method(*args)
      end
      def class_method(*args)
      end
      def constant(*args)
      end
    end

    temp_proxy.new.instance_eval(&block)
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
