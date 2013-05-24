def behavior_info(name, callbacks = {})
  $__behavior_info__ ||= {}
  $__behavior_info__[name.to_sym] = callbacks.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
end

alias :behaviour_info :behavior_info
alias :interface :behavior_info

class Object
  def behaves_as?(name)

    name = name.to_sym
    bi = $__behavior_info__[name]
    return false if bi.nil?

    bi.each do |method, arity|
      begin
        return false unless arity == :any || self.method(method).arity == arity
      rescue NameError
        return false
      end
    end

    return true
  end
end

def behavior(name)

  name = name.to_sym
  raise ArgumentError.new("undefined behavior '#{name}'") if $__behavior_info__[name].nil?

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
