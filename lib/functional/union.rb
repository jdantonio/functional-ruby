require_relative 'abstract_struct'

module Functional

  # An abstract base class from which all `Functional::Union` classes derive.
  #
  # @see Functional::Union
  class AbstractUnion < AbstractStruct

    # @!visibility private
    private_class_method :new

    private

    # Create a new union with the given member set to the given value.
    #
    # @param [Symbol] member the member in which to store the given value
    # @param [Object] value the value of the given member
    def initialize(member, value)
      @member = member
      @value = value
      data = members.reduce({}) do |memo, member|
        memo[member] = ( member == @member ? @value : nil )
        memo
      end
      set_data_hash(data)
      set_values_array(data.values)
    end
  end

  # An immutable data structure with multiple members, only one of which
  # can be set at any given time. A `Union` is a convenient way to bundle a
  # number of member attributes together, using accessor methods, without having
  # to write an explicit class.
  #
  # The `Union` module generates new `AbstractUnion` subclasses that hold a set of
  # members with one and only one value associated with a single member. For each
  # member a reader method is created along with a predicate and a factory. The
  # predicate method indicates whether or not the give member is set. The reader
  # method returns the value of that member or `nil` when not set. The factory
  # creates a new union with the appropriate member set with the given value.
  #
  # A `Union` is very similar to a Ruby `Struct` and shares many of its behaviors
  # and attributes. Where a `Struct` can have zero or more values, each of which is
  # assiciated with a member, a `Union` can have one and only one value. Unlike a
  # Ruby `Struct`, a `Union` is immutable: its value is set at construction and
  # it can never be changed. Divergence between the two classes derive from these
  # two core differences.
  #
  # @example
  # 
  #   LeftRightCenter = Functional::Union.new(:left, :right, :center) #=> LeftRightCenter
  #   LeftRightCenter.ancestors #=> [LeftRightCenter, Functional::AbstractUnion... ]
  #   LeftRightCenter.members   #=> [:left, :right, :center]
  #   
  #   prize = LeftRightCenter.right('One million dollars!') #=> #<union LeftRightCenter... >
  #   prize.members #=> [:left, :right, :center]
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
  # @see Functional::AbstractUnion
  # @see http://www.ruby-doc.org/core-2.1.2/Struct.html Ruby `Struct` class
  # @see http://en.wikipedia.org/wiki/Union_type "Union type" on Wikipedia
  module Union
    extend self

    # Create a new union class with the given members.
    #
    # @return [Functional::AbstractUnion] the new union subclass
    # @raise [ArgumentError] no members specified
    def new(*members)
      raise ArgumentError.new('no members provided') if members.empty?
      members = members.collect{|member| member.to_sym }.freeze
      build(Class.new(AbstractUnion), members)
    end

    private

    def build(union, members)
      union.send(:set_datatype, :union)
      set_members(union, members)
      define_properties(union)
      members.each do |member|
        define_reader(union, member)
        define_predicate(union, member)
        define_factory(union, member)
      end
      union
    end

    def set_members(union, members)
      union.send(:members=, members)
      union
    end

    def define_properties(union)
      union.send(:attr_reader, :member)
      union.send(:attr_reader, :value)
    end

    def define_predicate(union, member)
      union.send(:define_method, "#{member}?".to_sym) do
        @member == member
      end
      union
    end

    def define_reader(union, member)
      union.send(:define_method, member) do
        send("#{member}?".to_sym) ? @value : nil
      end
      union
    end

    def define_factory(union, member)
      union.class.send(:define_method, member) do |value|
        new(member, value).freeze
      end
      union
    end
  end
end
