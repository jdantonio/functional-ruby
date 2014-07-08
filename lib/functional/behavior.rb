module Functional

  BehaviorError = Class.new(StandardError)

  #def BehaviorInfo
  #end
  #alias_method :BehaviourInfo, :BehaviorInfo
  #module_function :BehaviorInfo
  #module_function :BehaviourInfo

  #module Behavior

    #def self.included(base)
      ## hook into object construction here
    #end
  #end

  #module BehaviorCheck

    #def BehavesAs?
    #end
    #alias_method :BehaveAs?, :BehavesAs?

    #def BehavesAs!
    #end
    #alias_method :BehaveAs!, :BehavesAs!
  #end
end

module Kernel

  # Define a behavioral specification (interface).
  #
  # @param name [Symbol] the name of the behavior
  # @param functions [Hash] function names and their arity as key/value pairs
  def behavior_info(name, functions = {})
    $__behavior_info__ ||= {}
    $__behavior_info__[name.to_sym] = functions.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end

  alias_method :behaviour_info, :behavior_info
  alias_method :interface, :behavior_info

  module_function :behavior_info
  module_function :behaviour_info
  module_function :interface

  # Specify a #behavior_info to enforce on the enclosing class
  #
  # {include:file:doc/behavior.md}
  #
  # @param name [Symbol] name of the #behavior_info being implemented
  def behavior(name)

    name = name.to_sym
    raise Functional::BehaviorError.new("undefined behavior '#{name}'") if $__behavior_info__[name].nil?

    clazz = self.method(:behavior).receiver

    unless clazz.instance_methods(false).include?(:behaviors)
      class << clazz
        def behaviors
          @behaviors ||= []
        end
      end
    end

    clazz.behaviors << name

    if self.class == Module
      (class << self; self; end).class_eval do
        define_method(:included) do |base|
          base.class_eval do
            behavior(name)
          end
        end
      end
  end

  if self.class == Class
    unless self.respond_to?(:__new)
      class << clazz
        alias_method(:__new, :new)
      end
    end
  end

  if Functional.configuration.behavior_check_on_construction?
    class << clazz
      def new(*args, &block)
        obj = __new(*args, &block)
        self.ancestors.each do |clazz|
          if clazz.respond_to?(:behaviors)
            clazz.behaviors.each do |behavior|
              valid = obj.behaves_as?(behavior, true)
            end
          end
        end
        return obj
      end
    end
  end
end

alias_method :behaviour, :behavior
alias_method :behaves_as, :behavior

module_function :behavior
module_function :behaviour
module_function :behaves_as
end

class Object

  # Does the object implement the given #behavior_info?
  #
  # @note Will return true if the object implements the required methods. The
  #   object's class hierarchy does not necessarily have to include a corresponding
  #   #behavior call.
  #
  # @param name [Symbol] name of the #behavior_info to verify behavior against.
  # @param abend [Boolean] raise an exception when true and the there are
  #   unimplemented methods
  #
  # @return [Boolean] whether or not the required public methods are implemented
  def behaves_as?(name, abend = false)

    name = name.to_sym
    bi = $__behavior_info__[name]
    return false if bi.nil?

    validator = proc do |obj, method, arity|
      (obj.respond_to?(method) && arity == :any) || obj.method(method).arity == arity
    end

    if self.is_a?(Class) || self.is_a?(Module)
      bi = bi.select{|method, arity| method.to_s =~ /^self_/ }
    end

    bi.each do |method, arity|
      begin
        func = method.to_s
        obj = self

        if (self.is_a?(Class) || self.is_a?(Module)) && func =~ /^self_/
          func = func.gsub(/^self_/, '')
        elsif method =~ /^self_/
          func = func.gsub(/^self_/, '')
          obj = self.class
        end

        valid = validator.call(obj, func, arity)
        raise NameError if abend && ! valid
        return valid unless valid
      rescue NameError
        if abend
          func = "#{method.to_s.gsub(/^self_/, 'self.')}/#{arity.to_s.gsub(/^any$/, ':any')}"
          raise Functional::BehaviorError.new("undefined callback function ##{func} in #{self} (behavior '#{name}')")
        else
          return false
        end
      end
    end

    return true
  end
end
