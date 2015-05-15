require 'functional/final_var'
require 'functional/synchronization'

module Functional

  # A variation on Ruby's `OpenStruct` in which all fields are "final" (meaning
  # that new fields can be arbitrarily added to a `FinalStruct` object but once
  # set each field becomes immutable). Additionally, predicate methods exist for
  # all fields and these predicates indicate if the field has been set.
  #
  # There are two ways to initialize a `FinalStruct`: with zero arguments or
  # with a `Hash` (or any other object that implements a `to_h` method). The
  # only difference in behavior is that a `FinalStruct` initialized with a
  # hash will pre-define and pre-populate attributes named for the hash keys
  # and with values corresponding to the hash values.
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
  # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/ostruct/rdoc/OpenStruct.html
  # @see http://en.wikipedia.org/wiki/Final_(Java) Java `final` keyword
  #
  # @!macro thread_safe_final_object
  class FinalStruct < Synchronization::Object

    # Creates a new `FinalStruct` object. By default, the resulting `FinalStruct`
    # object will have no attributes. The optional hash, if given, will generate
    # attributes and values (can be a `Hash` or any object with a `to_h` method).
    #
    # @param [Hash] attributes the field/value pairs to set on creation
    def initialize(attributes = {})
      raise ArgumentError.new('attributes must be given as a hash or not at all') unless attributes.respond_to?(:to_h)
      super
      synchronize do
        @attribute_hash = {}
        attributes.to_h.each_pair do |field, value|
          ns_set_attribute(field, value)
        end
      end
    end

    # @!macro [attach] final_struct_get_method
    #
    #   Get the value of the given field.
    #
    #   @param [Symbol] field the field to retrieve the value for
    #   @return [Object] the value of the field is set else nil
    def get(field)
      synchronize { ns_get_attribute(field) }
    end
    alias_method :[], :get

    # @!macro [attach] final_struct_set_method
    #
    #   Set the value of the give field to the given value.
    #
    #   It is a logical error to attempt to set a `final` field more than once, as this
    #   violates the concept of finality. Calling the method a second or subsequent time
    #   for a given field will result in an exception being raised.
    #
    #   @param [Symbol] field the field to set the value for
    #   @param [Object] value the value to set the field to
    #   @return [Object] the final value of the given field
    #
    # @raise [Functional::FinalityError] if the given field has already been set
    def set(field, value)
      synchronize do
        if ns_attribute_has_been_set?(field)
          raise FinalityError.new("final accessor '#{field}' has already been set")
        else
          ns_set_attribute(field, value)
        end
      end
    end
    alias_method :[]=, :set

    # @!macro [attach] final_struct_set_predicate
    #
    #   Check the internal hash to unambiguously verify that the given
    #   attribute has been set.
    #
    #   @param [Symbol] field the field to get the value for
    #   @return [Boolean] true if the field has been set else false
    def set?(field)
      synchronize { ns_attribute_has_been_set?(field) }
    end

    # Get the current value of the given field if already set else set the value of
    # the given field to the given value.
    #
    # @param [Symbol] field the field to get or set the value for
    # @param [Object] value the value to set the field to when not previously set
    # @return [Object] the final value of the given field
    def get_or_set(field, value)
      synchronize { ns_attribute_has_been_set?(field) ? ns_get_attribute(field) : ns_set_attribute(field, value) }
    end

    # Get the current value of the given field if already set else return the given
    # default value.
    #
    # @param [Symbol] field the field to get the value for
    # @param [Object] default the value to return if the field has not been set
    # @return [Object] the value of the given field else the given default value
    def fetch(field, default)
      synchronize { ns_attribute_has_been_set?(field) ? ns_get_attribute(field) : default }
    end

    # Calls the block once for each attribute, passing the key/value pair as parameters.
    # If no block is given, an enumerator is returned instead.
    #
    # @yieldparam [Symbol] field the struct field for the current iteration
    # @yieldparam [Object] value the value of the current field
    #
    # @return [Enumerable] when no block is given
    def each_pair
      return enum_for(:each_pair) unless block_given?
      synchronize do
        @attribute_hash.each do |field, value|
          yield(field, value)
        end
      end
    end

    # Converts the `FinalStruct` to a `Hash` with keys representing each attribute
    # (as symbols) and their corresponding values.
    # 
    # @return [Hash] a `Hash` representing this struct
    def to_h
      synchronize { @attribute_hash.dup }
    end

    # Compares this object and other for equality. A `FinalStruct` is `eql?` to
    # other when other is a `FinalStruct` and the two objects have identical
    # fields and values.
    #
    # @param [Object] other the other record to compare for equality
    # @return [Boolean] true when equal else false
    def eql?(other)
      other.is_a?(self.class) && to_h == other.to_h
    end
    alias_method :==, :eql?

    # Describe the contents of this object in a string.
    #
    # @return [String] the string representation of this object
    #
    # @!visibility private
    def inspect
      state = to_h.to_s.gsub(/^{/, '').gsub(/}$/, '')
      "#<#{self.class} #{state}>"
    end
    alias_method :to_s, :inspect

    protected

    # @!macro final_struct_get_method
    # @!visibility private
    def ns_get_attribute(field)
      @attribute_hash[field.to_sym]
    end

    # @!macro final_struct_set_method
    # @!visibility private
    def ns_set_attribute(field, value)
      @attribute_hash[field.to_sym] = value
    end

    # @!macro final_struct_set_predicate
    # @!visibility private
    def ns_attribute_has_been_set?(field)
      @attribute_hash.has_key?(field.to_sym)
    end

    # Check the method name and args for signatures matching potential
    # final attribute reader, writer, and predicate methods. If the signature
    # matches a reader or predicate, treat the attribute as unset. If the
    # signature matches a writer, attempt to set the new attribute.
    #
    # @param [Symbol] symbol the name of the called function
    # @param [Array] args zero or more arguments
    # @return [Object] the result of the proxied method or the `super` call
    #
    # @!visibility private
    def method_missing(symbol, *args)
      if args.length == 1 && (match = /([^=]+)=$/.match(symbol))
        set(match[1], args.first)
      elsif args.length == 0 && (match = /([^\?]+)\?$/.match(symbol))
        set?(match[1])
      elsif args.length == 0
        get(symbol)
      else
        super
      end
    end
  end
end
