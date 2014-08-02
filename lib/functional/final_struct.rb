require_relative 'final'

module Functional

  # A variation on Ruby's `OpenStruct` in which all fields are "final" and
  # exhibit the behavior of a `Functional::Final#final_attribute`. This means
  # that new fields can be arbitrarily added to a `FinalStruct` object but once
  # set each field becomes immutable. Additionally, predicate methods exist for
  # all fields and these predicates indicate if the field has been set.
  #
  # There are two ways to initialize a `FinalStruct`: with zero arguments or
  # with a `Hash`. The only difference in behavior is that a `FinalStruct`
  # initialized with a hash will pre-define and pre-populate fields named
  # after the hash keys and with values corresponding to the hash values.
  #
  # @example Instanciation With No Fields
  #   bucket = Functional::FinalStruct.new
  #
  #   bucket.foo      #=> nil
  #   bucket.foo?     #=> false
  #
  #   bucket.foo = 42 #=> 42
  #   bucket.foo      #=> 42
  #   bucket.foo?     #=> true
  #
  #   bucket.foo = 42 #=> Functional::FinalityError: final accessor 'bar' has already been set
  #
  # @example Instanciation With a Hash
  #   name = Functional::FinalStruct.new(first: 'Douglas', last: 'Adams')
  #
  #   name.first           #=> 'Douglas'
  #   name.last            #=> 'Adams'
  #   name.first?          #=> true
  #   name.last?           #=> true
  #
  #   name.middle #=> nil
  #   name.middle?         #=> false
  #   name.middle = 'Noel' #=> 'Noel'
  #   name.middle?         #=> true
  #
  #   name.first = 'Sam'   #=> Functional::FinalityError: final accessor 'first' has already been set
  #
  # @see Functional::Final
  # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/ostruct/rdoc/OpenStruct.html
  class FinalStruct
    include Functional::Final

    def initialize(attributes = {})
      raise ArgumentError.new('field/value pairs must be given as a hash or not at all') unless attributes.is_a?(Hash)
      @attribute_hash = {}
      attributes.each_pair{|field, value| add_new_field(field, value) }
    end

    def get(field)
      send(field)
    end
    alias_method :[], :get

    def set(field, value)
      send("#{field}=", value)
    end
    alias_method :[]=, :set

    def get_or_set(field, value)
      if send("#{field}?")
        send(field)
      else
        add_new_field(field, value)
      end
    end

    def fetch(field, default)
      send("#{field}?") ? send(field) : default
    end
    def each_pair
      return enum_for(:each_pair) unless block_given?
      @attribute_hash.each do |field, value|
        yield(field, value)
      end
    end

    def to_h
      @attribute_hash.dup
    end

    def eql?(other)
      to_h == other.to_h
    end
    alias_method :==, :eql?

    def inspect
      state = to_h.to_s.gsub(/^{/, '').gsub(/}$/, '')
      "#<#{self.class} #{state}>"
    end
    alias_method :to_s, :inspect

    private

    def add_new_field(field, value)
      field = field.to_sym
      singleton_class.send(:final_attribute, field)
      @attribute_hash[field] = value
      send("#{field}=", value)
      value
    end

    def method_missing(symbol, *args)
      if symbol =~ /([^=]+)=$/ && args.length == 1
        add_new_field($1, args.first)
      elsif symbol =~ /\?$/ && args.length == 0
        false
      elsif args.length == 0
        nil
      else
        super
      end
    end

    # Returns the object's singleton class.
    def singleton_class
      class << self
        self
      end
    end
  end
end
