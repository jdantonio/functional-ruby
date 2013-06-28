module Kernel

  # Define a behavioral specification (interface).
  #
  # @param name [Symbol] the name of the behavior
  # @param functions [Hash] function names and their arity as key/value pairs
  def behavior_info(name, functions = {})
    $__behavior_info__ ||= {}
    $__behavior_info__[name.to_sym] = functions.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end

  alias :behaviour_info :behavior_info
  alias :interface :behavior_info

  module_function :behavior_info
  module_function :behaviour_info
  module_function :interface

  # Specify a #behavior_info to enforce on the enclosing class
  #
  # @param name [Symbol] name of the #behavior_info being implemented
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

  module_function :behavior
  module_function :behaviour
  module_function :behaves_as
end

class Object

  # Does the object implement the given #behavior_info?
  #
  # @note Will return true if the object implements the
  # required methods. The object's class hierarchy does
  # not necessarily have to include a corresponding
  # #behavior call.
  #
  # @param name [Symbol] name of the #behavior_info to
  # verify behavior against.
  #
  # @return [Boolean] whether or not the required public
  # methods are implemented
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
