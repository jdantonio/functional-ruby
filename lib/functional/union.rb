module Functional

  class AbstractUnion

    attr_reader :member
    attr_reader :value
    attr_reader :values

    class << self
      attr_accessor :members
    end
    self.members = [].freeze

    private_class_method :members=
    private_class_method :new

    def each
      return enum_for(:each) unless block_given?
      members.each do |member|
        yield(self.send(member))
      end
    end

    def each_pair
      return enum_for(:each_pair) unless block_given?
      members.each do |member|
        yield(member, self.send(member))
      end
    end

    def eql?(other)
      self.class == other.class && self.to_h == other.to_h
    end
    alias_method :==, :eql?

    def inspect
      state = to_h.to_s.gsub(/^{/, '').gsub(/}$/, '')
      "#<union #{self.class} #{state}>"
    end
    alias_method :to_s, :inspect

    def length
      members.length
    end
    alias_method :size, :length

    def members
      self.class.members
    end

    def to_h
      each_pair.to_h
    end

    def to_a
      each.to_a
    end

    private

    def initialize(member, value)
      @member = member
      @value = value
      @values = to_a.freeze
    end
  end

  # @see http://en.wikipedia.org/wiki/Union_type
  # @see http://www.ruby-doc.org/core-2.1.2/Struct.html
  module Union
    extend self

    def new(*members)
      raise ArgumentError.new('no members provided') if members.empty?
      members = members.collect{|member| member.to_sym }.freeze
      build(Class.new(AbstractUnion), members)
    end

    private

    def build(union, members)
      set_members(union, members)
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
