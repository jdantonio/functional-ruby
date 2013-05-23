def behavior_info(name, callbacks = {})
  $__behavior_info__ ||= {}
  $__behavior_info__[name] = callbacks
end

alias :behaviour_info :behavior_info

class Object
  def behaves_as?(name)

    bi = $__behavior_info__[name]
    return true if bi.nil?

    bi.each do |method, arity|
      begin
        return false unless self.method(method).arity == arity
      rescue NameError
        return false
      end
    end

    return true
  end
end

def behavior(name)
  clazz = self.method(:behavior).receiver

  unless clazz.instance_methods(false).include?(:behaviors)
    class << clazz
      def behaviors
        @behaviors ||= []
      end
    end
  end

  clazz.behaviors << name

  class << clazz
    def new(*args, &block)
      name = self.behaviors.first
      obj = super
      unless obj.behaves_as?(name)
        raise ArgumentError.new("undefined callback functions in #{self} (behavior '#{name}')")
      else
        return obj
      end
    end
  end
end

alias :behaviour :behavior
alias :behaves_as :behavior
