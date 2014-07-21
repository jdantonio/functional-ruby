require_relative 'protocol_info'

module Functional

  # An exception indicating a problem during protocol processing.
  ProtocolError = Class.new(StandardError)

  def SpecifyProtocol(name, &block)
    name = name.to_sym
    protocol_info = Protocol.class_variable_get(:@@info)[name]

    return protocol_info unless block_given?

    if block_given? && ! protocol_info.nil?
      raise ProtocolError.new(":#{name} has already been defined")
    end

    info = ProtocolInfo.new(name, &block)
    Protocol.class_variable_get(:@@info)[name] = info
  end
  module_function :SpecifyProtocol

  # {include:file:doc/protocol.md}
  module Protocol

    @@info = {}

    # Does the given module/class/object fully satisfy the given protocol(s)?
    #
    # @param [Object] target the method/class/object to interrogate
    # @param [Symbol] protocols
    def Satisfy?(target, *protocols)
      raise ArgumentError.new('no protocols given') if protocols.empty?
      protocols.drop_while { |protocol|
        Protocol.satisfies?(target, protocol.to_sym)
      }.empty?
    end
    module_function :Satisfy?

    def Satisfy!(target, *protocols)
      Protocol::Satisfy?(target, *protocols) or
        Protocol.error(target, 'does not', protocols)
      target
    end
    module_function :Satisfy!

    def Specified?(*protocols)
      Protocol.undefined(*protocols).empty?
    end
    module_function :Specified?

    def Specified!(*protocols)
      (undefined = Protocol.undefined(*protocols)).empty? or
        raise ProtocolError.new("The following protocols are undefined: :#{undefined.join('; :')}.")
    end
    module_function :Specified!

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
