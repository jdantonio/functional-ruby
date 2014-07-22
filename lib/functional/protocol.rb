require_relative 'protocol_info'

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

    if block_given? && ! protocol_info.nil?
      raise ProtocolError.new(":#{name} has already been defined")
    end

    info = ProtocolInfo.new(name, &block)
    Protocol.class_variable_get(:@@info)[name] = info
  end
  module_function :SpecifyProtocol

  # Protocols provide a polymorphism and method-dispatch mechanism that exchews
  # stong typing and embraces the dynamic duck typing of Ruby. Rather than
  # interrogate a module, class, or object for its type and ancestry, protocols
  # allow modules, classes, and methods to be interrogated based on their behavior.
  # It is a logical extension of the `respond_to?` method, but vastly more powerful.
  # 
  # ## Rationale
  # 
  # Traditional object orientation implements polymorphism inheritance. The *Is-A*
  # relationship indicates that one object "is a" instance of another object.
  # Implicit in this relationship, however, is the concept of [type](http://en.wikipedia.org/wiki/Data_type).
  # Every Ruby object has a *type*, and that type is the name of its `Class` or
  # `Module`. The Ruby runtime provides a number of reflective methods that allow
  # objects to be interrogated for type information. The principal of thses is the
  # `is_a?` (alias `kind_of`) method defined in class `Object`.
  # 
  # Unlike many traditional object oriented languages, Ruby is a [dynamically typed](http://en.wikipedia.org/wiki/Dynamic_typing#DYNAMIC)
  # language. Types exist but the runtime is free to cast one type into another
  # at any time. Moreover, Ruby is a [duck typed](http://en.wikipedia.org/wiki/Duck_typing).
  # If an object "walks like a duck and quacks like a duck then it must be a duck."
  # When a method needs called on an object Ruby does not check the type of the object,
  # it simply checks to see if the requested function exists with the proper
  # [arity](http://en.wikipedia.org/wiki/Arity) and, if it does, dispatches the call.
  # The duck type analogue to `is_a?` is `respond_to?`. Thus an object can be interrogated
  # for its behavior rather than its type.
  # 
  # Although Ruby offers several methods for reflecting on the behavior of a module/class/object,
  # such as `method`, `instance_methods`, `const_defined?`, the aforementioned `respond_to?`,
  # and others, Ruby lacks a convenient way to group collections of methods in any way that
  # does not involve type. Both modules and classes provide mechanisms for combining
  # methods into cohesive abstractions, but they both imply type. This is anathema to Ruby's
  # dynamism and duck typing. What Ruby needs is a way to collect a group of method names
  # and signatures into a cohesive collection that embraces duck typing and dynamic dispatch.
  # This is what protocols do.
  # 
  # ## Specifying
  # 
  # A "protocol" is a loose collection of method, attribute, and constant names with optional
  # arity values. The protocol definition does very little on its own. The power of protocols
  # is that they provide a way for modules, classes, and objects to be interrogated with
  # respect to common behavior, not common type. At the core a protocol is nothing more
  # than a collection of `respond_to?` method calls that ask the question "Does this thing
  # *behave* like this other thing."
  # 
  # Protocols are specified with the `Functional::SpecifyProtocol` method. It takes one parameter,
  # the name of the protocol, and a block which contains the protocol specification. This registers
  # the protocol specification and makes it available for use later when interrogating ojects
  # for their behavior.
  # 
  # ### Defining Attributes, Methods, and Constants
  # 
  # A single protocol specification can include definition for attributes, methods,
  # and constants. Methods and attributes can be defined as class/module methods or
  # as instance methods. Within the a protocol specification each item must include
  # the symbolic name of the item being defined.
  # 
  # ```ruby
  # Functional::SpecifyProtocol(:KitchenSink) do
  #   instance_method     :instance_method
  #   class_method        :class_method
  #   attr_accessor       :attr_accessor
  #   attr_reader         :attr_reader
  #   attr_writer         :attr_writer
  #   class_attr_accessor :class_attr_accessor
  #   class_attr_reader   :class_attr_reader
  #   class_attr_writer   :class_attr_writer
  #   constant            :CONSTANT
  # end
  # ```
  # 
  # Definitions for accessors are expanded at specification into the apprporiate
  # method(s). Which means that this:
  # 
  # ```ruby
  # Functional::SpecifyProtocol(:Name) do
  #   attr_accessor :first
  #   attr_accessor :middle
  #   attr_accessor :last
  #   attr_accessor :suffix
  # end
  # ```
  # 
  # is the same as:
  # 
  # ```ruby
  # Functional::SpecifyProtocol(:Name) do
  #   instance_method :first
  #   instance_method :first=
  #   instance_method :middle
  #   instance_method :middle=
  #   instance_method :last
  #   instance_method :last=
  #   instance_method :suffix
  #   instance_method :suffix=
  # end
  # ```
  # 
  # Protocols only care about the methods themselves, not how they were declared.
  # 
  # ### Arity
  # 
  # In addition to defining *which* methods exist, the required method arity can
  # indicated. Arity is optional. When no arity is given any arity will be expected.
  # The arity rules follow those defined for the `#arity` method of Ruby's
  # [Method class](http://www.ruby-doc.org/core-2.1.2/Method.html#method-i-arity):
  # 
  # * Methods with a fixed number of arguments have a non-negative arity
  # * Methods with optional arguments have an arity `-n - 1`, where n is the number of required arguments
  # * Methods with a variable number of arguments have an arity of `-1`
  # 
  # ```ruby
  # Functional::SpecifyProtocol(:Foo) do
  #   instance_method :any_args
  #   instance_method :no_args, 0
  #   instance_method :three_args, 3
  #   instance_method :optional_args, -2
  #   instance_method :variable_args, -1
  # end
  # 
  # class Bar
  # 
  #   def any_args(a, b, c=1, d=2, *args)
  #   end
  #   
  #   def no_args
  #   end
  # 
  #   def three_args(a, b, c)
  #   end
  # 
  #   def optional_args(a, b=1, c=2)
  #   end
  # 
  #   def variable_args(*args)
  #   end
  # end
  # ```
  # 
  # ## Reflection
  # 
  # Once a protocol has been defined, any class, method, or object may be interrogated
  # for adherence to one or more protocol specifications. The methods of the
  # `Functional::Protocol` classes provide this capability. The `Satisfy?` method
  # takes a module/class/object as the first parameter and one or more protocol names
  # as the second and subsequent parameters. It returns a boolean value indicating
  # whether the given object satisfies the protocol requirements:
  # 
  # ```ruby
  # Functional::SpecifyProtocol(:Queue) do
  #   instance_method :push, 1
  #   instance_method :pop, 0
  #   instance_method :length, 0
  # end
  # 
  # Functional::SpecifyProtocol(:List) do
  #   instance_method :[]=, 2
  #   instance_method :[], 1
  #   instance_method :each, 0
  #   instance_method :length, 0
  # end
  # 
  # Functional::Protocol::Satisfy?(Queue, :Queue)        #=> true
  # Functional::Protocol::Satisfy?(Queue, :List)         #=> false
  # 
  # list = [1, 2, 3]
  # Functional::Protocol::Satisfy?(Array, :List, :Queue) #=> true
  # Functional::Protocol::Satisfy?(list, :List, :Queue)  #=> true
  # 
  # Functional::Protocol::Satisfy?(Hash, :Queue)         #=> false
  # 
  # Functional::Protocol::Satisfy?('foo bar baz', :List) #=> false
  # ```
  # 
  # The `Satisfy!` method performs the exact same check but instead raises an exception
  # when the protocol is not satisfied:
  # 
  # ```
  # 2.1.2 :021 > Functional::Protocol::Satisfy!(Queue, :List)
  # Functional::ProtocolError: Value (Class) 'Thread::Queue' does not behave as all of: :List.
  # 	from /Projects/functional-ruby/lib/functional/protocol.rb:67:in `error'
  # 	from /Projects/functional-ruby/lib/functional/protocol.rb:36:in `Satisfy!'
  # 	from (irb):21
  #   ...
  # ```
  # The `Functional::Protocol` module can be included within other classes
  # to eliminate the namespace requirement when calling:
  # 
  # ```ruby
  # class MessageFormatter
  #   include Functional::Protocol
  # 
  #   def format(message)
  #     if Satisfy?(message, :Internal)
  #       format_internal_message(message)
  #     elsif Satisfy?(message, :Error)
  #       format_error_message(message)
  #     else
  #       format_generic_message(message)
  #     end
  #   end
  # 
  #   private
  # 
  #   def format_internal_message(message)
  #     # format the message...
  #   end
  # 
  #   def format_error_message(message)
  #     # format the message...
  #   end
  # 
  #   def format_generic_message(message)
  #     # format the message...
  #   end
  # ```
  # 
  # ## Inspiration
  # 
  # Protocols and similar functionality exist in several other programming languages.
  # A few languages that provided inspiration for this inplementation are:
  # 
  # * Clojure [protocol](http://clojure.org/protocols)
  # * Erlang [behaviours](http://www.erlang.org/doc/design_principles/des_princ.html#id60128)
  # * Objective-C [protocol](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html)
  #   (and the corresponding Swift [protocol](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html))
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
      return ! info.nil? && info.satisfies?(target)
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
      target
    end
  end
end
