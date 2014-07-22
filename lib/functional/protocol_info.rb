module Functional

  # An immutable object describing a single protocol and capable of building
  # itself from a block. Used by {Functional#SpecifyProtocol}.
  # 
  # @see Functional::Protocol
  class ProtocolInfo

    # The symbolic name of the protocol
    attr_reader :name

    # Process a protocol specification block and build a new object.
    #
    # @param [Symbol] name the symbolic name of the protocol
    # @yield self to the given specification block
    # @return [Functional::ProtocolInfo] the new info object, frozen
    #
    # @raise [ArgumentError] when name is nil or an empty string
    # @raise [ArgumentError] when no block given
    def initialize(name, &specification)
      raise ArgumentError.new('no block given') unless block_given?
      raise ArgumentError.new('no name given') if name.nil? || name.empty?
      @name = name.to_sym
      @info = Info.new({}, {}, [])
      self.instance_eval(&specification)
      @info.each_pair{|col, _| col.freeze}
      @info.freeze
      self.freeze
    end

    # The instance methods expected by this protocol.
    #
    # @return [Hash] a frozen hash of all instance method names and their
    #   expected arity for this protocol
    def instance_methods
      @info.instance_methods
    end

    # The class methods expected by this protocol.
    #
    # @return [Hash] a frozen hash of all class method names and their
    #   expected arity for this protocol
    def class_methods
      @info.class_methods
    end

    # The constants expected by this protocol.
    #
    # @rerurn [Array] a frozen list of the constants expected by this protocol
    def constants
      @info.constants
    end

    # Does the given module/class/object satisfy this protocol?
    #
    # @return [Boolean] true if the target satisfies this protocol else false
    def satisfies?(target)
      satisfies_constants?(target) &&
        satisfies_instance_methods?(target) &&
        satisfies_class_methods?(target)
    end

    private

    # Data structure for encapsulating the protocol info data.
    Info = Struct.new(:instance_methods, :class_methods, :constants)

    # Does the target satisfy the constants expected by this protocol?
    #
    # @param [target] target the module/class/object to interrogate
    # @return [Boolean] true when satisfied else false
    def satisfies_constants?(target)
      clazz = target.is_a?(Module) ? target : target.class
      @info.constants.all?{|constant| clazz.const_defined?(constant) }
    end

    # Does the target satisfy the instance methods expected by this protocol?
    #
    # @param [target] target the module/class/object to interrogate
    # @return [Boolean] true when satisfied else false
    def satisfies_instance_methods?(target)
      @info.instance_methods.all? do |method, arity|
        if target.is_a? Module
          target.method_defined?(method) && check_arity?(target.instance_method(method), arity)
        else
          target.respond_to?(method) && check_arity?(target.method(method), arity)
        end
      end
    end


    # Does the target satisfy the class methods expected by this protocol?
    #
    # @param [target] target the module/class/object to interrogate
    # @return [Boolean] true when satisfied else false
    def satisfies_class_methods?(target)
      clazz = target.is_a?(Module) ? target : target.class
      @info.class_methods.all? do |method, arity|
        break false unless clazz.respond_to? method
        method = clazz.method(method)
        check_arity?(method, arity)
      end
    end

    # Does the given method have the expected arity? Returns true
    # if the arity of the method is `-1` (variable length argument list
    # with no required arguments), when expected is `nil` (indicating any
    # arity is acceptable), or the arity of the method exactly matches the
    # expected arity.
    #
    # @param [Method] method the method object to interrogate
    # @param [Fixnum] expected the expected arity
    # @return [Boolean] true when an acceptable match else false
    #
    # @see http://www.ruby-doc.org/core-2.1.2/Method.html#method-i-arity Method#arity
    def check_arity?(method, expected)
      arity = method.arity
      expected.nil? || arity == -1 || expected == arity
    end

    #################################################################
    # DSL methods

    # Specify an instance method.
    #
    # @param [Symbol] name the name of the method
    # @param [Fixnum] arity the required arity
    def instance_method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.instance_methods[name.to_sym] = arity
    end

    # Specify a class method.
    #
    # @param [Symbol] name the name of the method
    # @param [Fixnum] arity the required arity
    def class_method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.class_methods[name.to_sym] = arity
    end

    # Specify an instance reader attribute.
    #
    # @param [Symbol] name the name of the attribute
    def attr_reader(name)
      instance_method(name, 0)
    end

    # Specify an instance writer attribute.
    #
    # @param [Symbol] name the name of the attribute
    def attr_writer(name)
      instance_method("#{name}=".to_sym, 1)
    end

    # Specify an instance accessor attribute.
    #
    # @param [Symbol] name the name of the attribute
    def attr_accessor(name)
      attr_reader(name)
      attr_writer(name)
    end

    # Specify a class reader attribute.
    #
    # @param [Symbol] name the name of the attribute
    def class_attr_reader(name)
      class_method(name, 0)
    end

    # Specify a class writer attribute.
    #
    # @param [Symbol] name the name of the attribute
    def class_attr_writer(name)
      class_method("#{name}=".to_sym, 1)
    end

    # Specify a class accessor attribute.
    #
    # @param [Symbol] name the name of the attribute
    def class_attr_accessor(name)
      class_attr_reader(name)
      class_attr_writer(name)
    end

    # Specify a constant.
    #
    # @param [Symbol] name the name of the constant
    def constant(name)
      @info.constants << name.to_sym
    end
  end
end
