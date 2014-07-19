module Functional

  ProtocolError = Class.new(StandardError)

  class ProtocolInfo

    Info = Struct.new(:methods, :class_methods, :constants)

    def initialize(&definition)
      @info = Info.new({}, {}, [])
      self.instance_eval(&definition)
      self.freeze
    end

    #def to_h
      #{
        #methods: @info.methods,
        #class_methods: @info.class_methods,
        #constants: @info.constants
      #}.freeze
    #end

    def satisfies?(target)
      target.class # trigger lazy loading
      clazz = target.is_a?(Module) ? target : target.class

      results = @info.constants.drop_while do |constant|
        check_constant?(target, constant)
      end
      return false unless results.empty?

      results = @info.methods.drop_while do |method, arity|
        check_arity?(target, method, arity)
      end
      return false unless results.empty?

      results = @info.class_methods.drop_while do |method, arity|
        check_arity?(clazz, method, arity)
      end

      results.empty?
    end

    private

    # @!visibility private
    def method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.methods[name.to_sym] = arity
    end

    # @!visibility private
    def class_method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.class_methods[name.to_sym] = arity
    end

    # @!visibility private
    def attr_reader(name)
      method(name, 0)
    end

    # @!visibility private
    def attr_writer(name)
      method("#{name}=".to_sym, 1)
    end

    # @!visibility private
    def attr_accessor(name)
      attr_reader(name)
      attr_writer(name)
    end

    # @!visibility private
    def class_attr_reader(name)
      class_method(name, 0)
    end

    # @!visibility private
    def class_attr_writer(name)
      class_method("#{name}=".to_sym, 1)
    end

    # @!visibility private
    def class_attr_accessor(name)
      class_attr_reader(name)
      class_attr_writer(name)
    end

    # @!visibility private
    def constant(name)
      @info.constants << name.to_sym
    end

    # @!visibility private
    def check_arity?(target, method, expected)
      return false unless target.respond_to? method
      arity = target.method(method).arity
      expected.nil? || arity == -1 || expected == arity
    end

    # @!visibility private
    def check_constant?(target, constant)
      target = target.class unless target.is_a?(Module)
      target.class.const_defined?(constant)
    end
  end

  def DefineProtocol(protocol, &block)
    protocol = protocol.to_sym
    protocol_info = ProtocolCheck.class_variable_get(:@@info)[protocol]

    return protocol_info unless block_given?

    if block_given? && ! protocol_info.nil?
      raise ProtocolError.new(":#{protocol} has already been defined")
    end

    info = ProtocolInfo.new(&block)
    ProtocolCheck.class_variable_get(:@@info)[protocol] = info
  end
  module_function :DefineProtocol

  module ProtocolCheck

    @@info = {}

    def Satisfy?(target, *protocols)
      protocols.drop_while { |protocol|
        ProtocolCheck.satisfies?(target, protocol.to_sym)
      }.empty?
    end

    def Satisfy!(target, *protocols)
      Satisfy?(target, *protocols) or
        ProtocolCheck.error(target, 'does not', protocols)
      target
    end

    def Protocol?(*protocols)
      ProtocolCheck.undefined?(*protocols).empty?
    end

    def Protocol!(*protocols)
      (undefined = ProtocolCheck.undefined?(*protocols)).empty? or
        raise ProtocolError.new("The following protocols are undefined: :#{undefined.join('; :')}.")
    end

    private

    #def self.check_arity?(target, method, expected)
      #return false unless target.respond_to? method
      #arity = target.method(method).arity
      #expected.nil? || arity == -1 || expected == arity
    #end

    #def self.check_constant?(target, constant)
      #target = target.class unless target.is_a?(Module)
      #target.class.const_defined?(constant)
    #end

    def self.satisfies?(target, protocol)
      info = @@info[protocol]
      return ! info.nil? && info.satisfies?(protocol)




      
      #target.class # trigger lazy loading
      #clazz = target.is_a?(Module) ? target : target.class
      #info = @@info[protocol]
      #return false if info.nil?

      #results = info[:constants].drop_while do |constant|
        #check_constant?(target, constant)
      #end
      #return false unless results.empty?

      #results = info[:methods].drop_while do |method, arity|
        #check_arity?(target, method, arity)
      #end
      #return false unless results.empty?

      #results = info[:class_methods].drop_while do |method, arity|
        #check_arity?(clazz, method, arity)
      #end

      #results.empty?
    end

    def self.undefined?(*protocols)
      protocols.drop_while do |protocol|
        @@info.has_key? protocol.to_sym
      end
    end

    def self.error(target, message, protocols)
      target = target.class unless target.is_a?(Module)
      raise ProtocolError,
        "Value (#{target.class}) '#{target}' #{message} behave as all of: :#{protocols.join('; :')}."
      target
    end
  end
end
