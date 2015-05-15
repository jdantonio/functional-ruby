require 'functional/synchronization'

module Functional

  # A variation on Ruby's `OpenStruct` in which all fields are immutable and
  # set at instantiation. For compatibility with {Functional::FinalStruct}, 
  # predicate methods exist for all potential fields and these predicates
  # indicate if the field has been set. Calling a predicate method for a field
  # that does not exist on the struct will return false.
  #
  # Unlike {Functional::Record}, which returns a new class which can be used to
  # create immutable objects, `ValueStruct` creates simple immutable objects.
  #
  # @example Instanciation
  #   name = Functional::ValueStruct.new(first: 'Douglas', last: 'Adams')
  #
  #   name.first   #=> 'Douglas'
  #   name.last    #=> 'Adams'
  #   name.first?  #=> true
  #   name.last?   #=> true
  #   name.middle? #=> false
  #
  # @see Functional::Record
  # @see Functional::FinalStruct
  # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/ostruct/rdoc/OpenStruct.html
  #
  # @!macro thread_safe_immutable_object
  class ValueStruct < Synchronization::Object

    def initialize(attributes)
      raise ArgumentError.new('attributes must be given as a hash') unless attributes.respond_to?(:each_pair)
      super
      @attribute_hash = {}
      attributes.each_pair do |field, value|
        set_attribute(field, value)
      end
      @attribute_hash.freeze
      ensure_ivar_visibility!
      self.freeze
    end

    # Get the value of the given field.
    #
    # @param [Symbol] field the field to retrieve the value for
    # @return [Object] the value of the field is set else nil
    def get(field)
      @attribute_hash[field.to_sym]
    end
    alias_method :[], :get

    # Check the internal hash to unambiguously verify that the given
    # attribute has been set.
    #
    # @param [Symbol] field the field to get the value for
    # @return [Boolean] true if the field has been set else false
    def set?(field)
      @attribute_hash.has_key?(field.to_sym)
    end

    # Get the current value of the given field if already set else return the given
    # default value.
    #
    # @param [Symbol] field the field to get the value for
    # @param [Object] default the value to return if the field has not been set
    # @return [Object] the value of the given field else the given default value
    def fetch(field, default)
      @attribute_hash.fetch(field.to_sym, default)
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
      @attribute_hash.each do |field, value|
        yield(field, value)
      end
    end

    # Converts the `ValueStruct` to a `Hash` with keys representing each attribute
    # (as symbols) and their corresponding values.
    # 
    # @return [Hash] a `Hash` representing this struct
    def to_h
      @attribute_hash.dup # dup removes the frozen flag
    end

    # Compares this object and other for equality. A `ValueStruct` is `eql?` to
    # other when other is a `ValueStruct` and the two objects have identical
    # fields and values.
    #
    # @param [Object] other the other record to compare for equality
    # @return [Boolean] true when equal else false
    def eql?(other)
      other.is_a?(self.class) && @attribute_hash == other.to_h
    end
    alias_method :==, :eql?

    # Describe the contents of this object in a string.
    #
    # @return [String] the string representation of this object
    #
    # @!visibility private
    def inspect
      state = @attribute_hash.to_s.gsub(/^{/, '').gsub(/}$/, '')
      "#<#{self.class} #{state}>"
    end
    alias_method :to_s, :inspect

    protected

    # Set the value of the give field to the given value.
    #
    # @param [Symbol] field the field to set the value for
    # @param [Object] value the value to set the field to
    # @return [Object] the final value of the given field
    #
    # @!visibility private
    def set_attribute(field, value)
      @attribute_hash[field.to_sym] = value
    end

    # Check the method name and args for signatures matching potential
    # final predicate methods. If the signature matches call the appropriate
    # method
    #
    # @param [Symbol] symbol the name of the called function
    # @param [Array] args zero or more arguments
    # @return [Object] the result of the proxied method or the `super` call
    #
    # @!visibility private
    def method_missing(symbol, *args)
      if args.length == 0 && (match = /([^\?]+)\?$/.match(symbol))
        set?(match[1])
      elsif args.length == 0 && set?(symbol)
        get(symbol)
      else
        super
      end
    end
  end
end
