require_relative 'protocol_info'

module Functional

  ProtocolError = Class.new(StandardError)

  def DefineProtocol(name, &block)
    name = name.to_sym
    protocol_info = ProtocolCheck.class_variable_get(:@@info)[name]

    return protocol_info unless block_given?

    if block_given? && ! protocol_info.nil?
      raise ProtocolError.new(":#{name} has already been defined")
    end

    info = ProtocolInfo.new(name, &block)
    ProtocolCheck.class_variable_get(:@@info)[name] = info
  end
  module_function :DefineProtocol

  module ProtocolCheck

    @@info = {}

    def Satisfy?(target, *protocols)
      protocols.drop_while { |protocol|
        ProtocolCheck.satisfies?(target, protocol.to_sym)
      }.empty?
    end
    module_function :Satisfy?

    def Satisfy!(target, *protocols)
      ProtocolCheck::Satisfy?(target, *protocols) or
        ProtocolCheck.error(target, 'does not', protocols)
      target
    end
    module_function :Satisfy!

    def Protocol?(*protocols)
      ProtocolCheck.undefined(*protocols).empty?
    end
    module_function :Protocol?

    def Protocol!(*protocols)
      (undefined = ProtocolCheck.undefined(*protocols)).empty? or
        raise ProtocolError.new("The following protocols are undefined: :#{undefined.join('; :')}.")
    end
    module_function :Protocol!

    private

    def self.satisfies?(target, protocol)
      info = @@info[protocol]
      return ! info.nil? && info.satisfies?(target)
    end

    def self.undefined(*protocols)
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
