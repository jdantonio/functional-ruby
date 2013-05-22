# http://metajack.im/2008/10/29/custom-behaviors-in-erlang/

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
        raise ArgumentError.new("#{self} is behaving badly. It should be a #{name} but isn't.")
      else
        return obj
      end
    end
  end
end

alias :behaviour :behavior

###############################################################################################

behaviour_info(:gen_foo, foo: 0, bar: 1, baz: 2);

class Foo
  behavior :gen_foo

  def foo
    return 'foo/0'
  end

  def bar(one)
    return 'bar/1'
  end

  def baz(one, two)
    return 'baz/2'
  end
end

class Bar
  behavior :gen_foo

  def foo(one)
    return 'foo/1'
  end
end

class Baz
  behavior :gen_foo
end

