module Functional

  class ProtocolInfo

    attr_reader :name

    def initialize(name, &definition)
      raise ArgumentError.new('no block given') unless block_given?
      raise ArgumentError.new('no name given') if name.nil? || name.empty?
      @name = name.to_sym
      @info = Info.new({}, {}, [])
      self.instance_eval(&definition)
      @info.each_pair{|col, _| col.freeze}
      @info.freeze
      self.freeze
    end

    def instance_methods
      @info.instance_methods
    end

    def class_methods
      @info.class_methods
    end

    def constants
      @info.constants
    end

    def satisfies?(target)
      satisfies_constants?(target) &&
        satisfies_instance_methods?(target) &&
        satisfies_class_methods?(target)
    end

    private

    Info = Struct.new(:instance_methods, :class_methods, :constants)

    def satisfies_constants?(target)
      clazz = target.is_a?(Module) ? target : target.class
      @info.constants.drop_while { |constant|
        check_constant?(clazz, constant)
      }.empty?
    end

    def satisfies_instance_methods?(target)
      @info.instance_methods.drop_while { |method, arity|
        method = target.is_a?(Module) ? target.instance_method(method) : target.method(method)
        check_arity?(method, arity)
      }.empty?
    rescue NameError
      false
    end

    def satisfies_class_methods?(target)
      clazz = target.is_a?(Module) ? target : target.class
      @info.class_methods.drop_while { |method, arity|
        method = clazz.method(method)
        check_arity?(method, arity)
      }.empty?
    rescue NameError
      false
    end

    def check_arity?(method, expected)
      arity = method.arity
      expected.nil? || arity == -1 || expected == arity
    end

    def check_constant?(clazz, constant)
      clazz.const_defined?(constant)
    end

    #################################################################
    # DSL methods

    def instance_method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.instance_methods[name.to_sym] = arity
    end

    def class_method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.class_methods[name.to_sym] = arity
    end

    def attr_reader(name)
      instance_method(name, 0)
    end

    def attr_writer(name)
      instance_method("#{name}=".to_sym, 1)
    end

    def attr_accessor(name)
      attr_reader(name)
      attr_writer(name)
    end

    def class_attr_reader(name)
      class_method(name, 0)
    end

    def class_attr_writer(name)
      class_method("#{name}=".to_sym, 1)
    end

    def class_attr_accessor(name)
      class_attr_reader(name)
      class_attr_writer(name)
    end

    def constant(name)
      @info.constants << name.to_sym
    end
  end
end
