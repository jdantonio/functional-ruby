


Customer = Struct.new(:name, :address) do
  def greeting
    "Hello #{name}!"
  end
end

Customer.class #=> Class
Customer.ancestors #=> [Customer, Struct, Enumerable, Object, PP::ObjectMixin, Kernel, BasicObject]

Customer.new #=> #<struct Customer name=nil, address=nil>

dave = Customer.new('Dave', '123 Main')
dave.name #=> "Dave"
dave.greeting #=> "Hello Dave!"

class AbstractUnion

  @@formats = [].freeze

  attr_reader :value

  def each
    return enum_for(:each) unless block_given?
    formats.each do |format|
      yield(format, self.send(format))
    end
  end

  protected

  def formats
    @@formats
  end

  private

  def initialize(format, value)
    @format = format
    @value = value
  end
end

class TripleThreat < AbstractUnion

  @@formats = [:foo, :bar, :baz].freeze

  # factories

  def self.foo(value)
    new(:foo, value).freeze
  end

  def self.bar(value)
    new(:bar, value).freeze
  end

  def self.baz(value)
    new(:baz, value).freeze
  end

  # readers

  def foo
    foo? ? @value : nil
  end

  def bar
    bar? ? @value : nil
  end

  def baz
    baz? ? @value : nil
  end

  # predicates

  def foo?
    @format == :foo
  end

  def bar?
    @format == :bar
  end

  def baz?
    @format == :baz
  end
end

module Functional

  class AbstractUnion

    @@formats = [].freeze

    attr_reader :value

    def each
      return enum_for(:each) unless block_given?
      formats.each do |format|
        yield(format, self.send(format))
      end
    end

    def formats
      self.class.formats
    end

    def self.formats
      @@formats
    end

    private

    def initialize(format, value)
      @format = format
      @value = value
    end
  end

  # @see http://en.wikipedia.org/wiki/Union_type
  # @see http://www.ruby-doc.org/core-2.1.2/Struct.html
  class Union

    def self.new(*formats)
      raise ArgumentError.new('no formats provided') if formats.empty?
      formats = formats.collect{|format| format.to_sym }.freeze
      
      union = Class.new(AbstractUnion) do
        formats.each do |format|
          # predicates
          define_method("#{format}?".to_sym) do
            @format == format
          end
          # readers
          define_method(format) do
            send("#{format}?".to_sym) ? @value : nil
          end
        end
      end

      # possible formats
      union.class_variable_set(:@@formats, formats)

      # factories
      formats.each do |format|
        union.class.send(:define_method, format) do |value|
          new(format, value).freeze
        end
      end

      union
    end

    private :initialize
  end
end
