require_relative 'abstract_struct'

module Functional

  # An immutable data structure with multiple fields, only one of which
  # can be set at any given time. A `Union` is a convenient way to bundle a
  # number of field attributes together, using accessor methods, without having
  # to write an explicit class.
  #
  # The `Union` module generates new `AbstractStruct` subclasses that hold a set of
  # fields with one and only one value associated with a single field. For each
  # field a reader method is created along with a predicate and a factory. The
  # predicate method indicates whether or not the give field is set. The reader
  # method returns the value of that field or `nil` when not set. The factory
  # creates a new union with the appropriate field set with the given value.
  #
  # A `Union` is very similar to a Ruby `Struct` and shares many of its behaviors
  # and attributes. Where a `Struct` can have zero or more values, each of which is
  # assiciated with a field, a `Union` can have one and only one value. Unlike a
  # Ruby `Struct`, a `Union` is immutable: its value is set at construction and
  # it can never be changed. Divergence between the two classes derive from these
  # two core differences.
  #
  # @example Creating a New Class
  # 
  #   LeftRightCenter = Functional::Union.new(:left, :right, :center) #=> LeftRightCenter
  #   LeftRightCenter.ancestors #=> [LeftRightCenter, Functional::AbstractStruct... ]
  #   LeftRightCenter.fields   #=> [:left, :right, :center]
  #   
  #   prize = LeftRightCenter.right('One million dollars!') #=> #<union LeftRightCenter... >
  #   prize.fields #=> [:left, :right, :center]
  #   prize.values  #=> [nil, "One million dollars!", nil]
  #   
  #   prize.left?   #=> false
  #   prize.right?  #=> true
  #   prize.center? #=> false
  #   
  #   prize.left    #=> nil
  #   prize.right   #=> "One million dollars!"
  #   prize.center  #=> nil
  #
  # @example Registering a New Class with Union
  #
  #   Functional::Union.new('Suit', :clubs, :diamonds, :hearts, :spades)
  #    #=> Functional::Union::Suit
  #
  #   Functional::Union::Suit.hearts('Queen')
  #    #=> #<union Functional::Union::Suit :clubs=>nil, :diamonds=>nil, :hearts=>"Queen", :spades=>nil>
  #
  # @see Functional::AbstractStruct
  # @see Functional::Union
  # @see http://www.ruby-doc.org/core-2.1.2/Struct.html Ruby `Struct` class
  # @see http://en.wikipedia.org/wiki/Union_type "Union type" on Wikipedia
  #
  # @!macro thread_safe_immutable_object
  module Union
    extend self

    # Create a new union class with the given fields.
    #
    # @return [Functional::AbstractStruct] the new union subclass
    # @raise [ArgumentError] no fields specified
    def new(*fields)
      raise ArgumentError.new('no fields provided') if fields.empty?
      build(fields)
    end

    private

    # Use the given `AbstractStruct` class and build the methods necessary
    # to support the given data fields.
    #
    # @param [Array] fields the list of symbolic names for all data fields
    # @return [Functional::AbstractStruct] the union class
    def build(fields)
      union, fields = AbstractStruct.define_class(self, :union, fields)
      union.private_class_method(:new)
      define_properties(union)
      define_initializer(union)
      fields.each do |field|
        define_reader(union, field)
        define_predicate(union, field)
        define_factory(union, field)
      end
      union
    end

    # Define the `field` and `value` attribute readers on the given union class.
    #
    # @param [Functional::AbstractStruct] union the new union class
    # @return [Functional::AbstractStruct] the union class
    def define_properties(union)
      union.send(:attr_reader, :field)
      union.send(:attr_reader, :value)
      union
    end

    # Define a predicate method on the given union class for the given data field.
    #
    # @param [Functional::AbstractStruct] union the new union class
    # @param [Symbol] field symbolic name of the current data field
    # @return [Functional::AbstractStruct] the union class
    def define_predicate(union, field)
      union.send(:define_method, "#{field}?".to_sym) do
        @field == field
      end
      union
    end

    # Define a reader method on the given union class for the given data field.
    #
    # @param [Functional::AbstractStruct] union the new union class
    # @param [Symbol] field symbolic name of the current data field
    # @return [Functional::AbstractStruct] the union class
    def define_reader(union, field)
      union.send(:define_method, field) do
        send("#{field}?".to_sym) ? @value : nil
      end
      union
    end

    # Define an initializer method on the given union class.
    #
    # @param [Functional::AbstractStruct] union the new union class
    # @return [Functional::AbstractStruct] the union class
    def define_initializer(union)
      union.send(:define_method, :initialize) do |field, value|
        @field = field
        @value = value
        data = fields.reduce({}) do |memo, field|
          memo[field] = ( field == @field ? @value : nil )
          memo
        end
        set_data_hash(data)
        set_values_array(data.values)
      end
      union
    end

    # Define a factory method on the given union class for the given data field.
    #
    # @param [Functional::AbstractStruct] union the new union class
    # @param [Symbol] field symbolic name of the current data field
    # @return [Functional::AbstractStruct] the union class
    def define_factory(union, field)
      union.class.send(:define_method, field) do |value|
        new(field, value).freeze
      end
      union
    end
  end
end
