require 'functional/protocol_info'

module Functional

  # An exception indicating a problem during protocol processing.
  ProtocolError = Class.new(StandardError)

  # Specify a new protocol or retrieve the specification of an existing
  # protocol.
  #
  # When called without a block the global protocol registry will be searched
  # for a protocol with the matching name. If found the corresponding
  # {Functional::ProtocolInfo} object will be returned. If not found `nil` will
  # be returned.
  #
  # When called with a block, a new protocol with the given name will be
  # created and the block will be processed to provide the specifiction.
  # When successful the new {Functional::ProtocolInfo} object will be returned.
  # An exception will be raised if a protocol with the same name already
  # exists.
  #
  # @example
  #   Functional::SpecifyProtocol(:Queue) do
  #     instance_method :push, 1
  #     instance_method :pop, 0
  #     instance_method :length, 0
  #   end
  #
  # @param [Symbol] name The global name of the new protocol
  # @yield The protocol definition
  # @return [Functional::ProtocolInfo] the newly created or already existing
  #   protocol specification
  #
  # @raise [Functional::ProtocolError] when attempting to specify a protocol
  #   that has already been specified.
  #
  # @see Functional::Protocol
  def SpecifyProtocol(name, &block)
    name = name.to_sym
    protocol_info = Protocol.class_variable_get(:@@info)[name]

    return protocol_info unless block_given?

    if block_given? && protocol_info
      raise ProtocolError.new(":#{name} has already been defined")
    end

    info = ProtocolInfo.new(name, &block)
    Protocol.class_variable_get(:@@info)[name] = info
  end
  module_function :SpecifyProtocol

  # Protocols provide a polymorphism and method-dispatch mechanism that eschews
  # strong typing and embraces the dynamic duck typing of Ruby. Rather than
  # interrogate a module, class, or object for its type and ancestry, protocols
  # allow modules, classes, and methods to be interrogated based on their behavior.
  # It is a logical extension of the `respond_to?` method, but vastly more powerful.
  #
  # {include:file:doc/protocol.md}
  module Protocol

    # The global registry of specified protocols.
    @@info = {}

    # Does the given module/class/object fully satisfy the given protocol(s)?
    #
    # @param [Object] target the method/class/object to interrogate
    # @param [Symbol] protocols one or more protocols to check against the target
    # @return [Boolean] true if the target satisfies all given protocols else false
    #
    # @raise [ArgumentError] when no protocols given
    def Satisfy?(target, *protocols)
      raise ArgumentError.new('no protocols given') if protocols.empty?
      protocols.all?{|protocol| Protocol.satisfies?(target, protocol.to_sym) }
    end
    module_function :Satisfy?

    # Does the given module/class/object fully satisfy the given protocol(s)?
    # Raises a {Functional::ProtocolError} on failure.
    #
    # @param [Object] target the method/class/object to interrogate
    # @param [Symbol] protocols one or more protocols to check against the target
    # @return [Symbol] the target
    #
    # @raise [Functional::ProtocolError] when one or more protocols are not satisfied
    # @raise [ArgumentError] when no protocols given
    def Satisfy!(target, *protocols)
      Protocol::Satisfy?(target, *protocols) or
        Protocol.error(target, 'does not', *protocols)
      target
    end
    module_function :Satisfy!

    # Have the given protocols been specified?
    #
    # @param [Symbol] protocols the list of protocols to check
    # @return [Boolean] true if all given protocols have been specified else false
    #
    # @raise [ArgumentError] when no protocols are given
    def Specified?(*protocols)
      raise ArgumentError.new('no protocols given') if protocols.empty?
      Protocol.unspecified(*protocols).empty?
    end
    module_function :Specified?

    # Have the given protocols been specified?
    # Raises a {Functional::ProtocolError} on failure.
    #
    # @param [Symbol] protocols the list of protocols to check
    # @return [Boolean] true if all given protocols have been specified
    #
    # @raise [Functional::ProtocolError] if one or more of the given protocols have
    #   not been specified
    # @raise [ArgumentError] when no protocols are given
    def Specified!(*protocols)
      raise ArgumentError.new('no protocols given') if protocols.empty?
      (unspecified = Protocol.unspecified(*protocols)).empty? or
        raise ProtocolError.new("The following protocols are unspecified: :#{unspecified.join('; :')}.")
    end
    module_function :Specified!

    private

    # Does the target satisfy the given protocol?
    #
    # @param [Object] target the module/class/object to check
    # @param [Symbol] protocol the protocol to check against the target
    # @return [Boolean] true if the target satisfies the protocol else false
    def self.satisfies?(target, protocol)
      info = @@info[protocol]
      return info && info.satisfies?(target)
    end

    # Reduces a list of protocols to a list of unspecified protocols.
    #
    # @param [Symbol] protocols the list of protocols to check
    # @return [Array] zero or more unspecified protocols
    def self.unspecified(*protocols)
      protocols.drop_while do |protocol|
        @@info.has_key? protocol.to_sym
      end
    end

    # Raise a {Functional::ProtocolError} formatted with the given data.
    #
    # @param [Object] target the object that was being interrogated
    # @param [String] message the message fragment to inject into the error
    # @param [Symbol] protocols list of protocols that were being checked against the target
    #
    # @raise [Functional::ProtocolError] the formatted exception object
    def self.error(target, message, *protocols)
      target = target.class unless target.is_a?(Module)
      raise ProtocolError,
        "Value (#{target.class}) '#{target}' #{message} behave as all of: :#{protocols.join('; :')}."
    end
  end
end
