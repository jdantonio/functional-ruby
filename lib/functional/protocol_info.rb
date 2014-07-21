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
      target.class # trigger lazy loading
      clazz = target.is_a?(Module) ? target : target.class

      results = @info.constants.drop_while do |constant|
        check_constant?(target, constant)
      end
      return false unless results.empty?

      results = @info.instance_methods.drop_while do |method, arity|
        check_arity?(target, method, arity)
      end
      return false unless results.empty?

      results = @info.class_methods.drop_while do |method, arity|
        check_arity?(clazz, method, arity)
      end

      results.empty?
    end

    private

    Info = Struct.new(:instance_methods, :class_methods, :constants)

    # @!visibility private
    def instance_method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.instance_methods[name.to_sym] = arity
    end

    # @!visibility private
    def class_method(name, arity = nil)
      arity = arity.to_i unless arity.nil?
      @info.class_methods[name.to_sym] = arity
    end

    # @!visibility private
    def attr_reader(name)
      instance_method(name, 0)
    end

    # @!visibility private
    def attr_writer(name)
      instance_method("#{name}=".to_sym, 1)
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
end
