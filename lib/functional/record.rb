require_relative 'abstract_struct'
require_relative 'type_check'

module Functional

  # An immutable data structure with multiple data fields. A `Record` is a
  # convenient way to bundle a number of field attributes together,
  # using accessor methods, without having to write an explicit class.
  # The `Record` module generates new `AbstractStruct` subclasses that hold a
  # set of fields with a reader method for each field.
  # 
  # A `Record` is very similar to a Ruby `Struct` and shares many of its behaviors
  # and attributes. Unlike a # Ruby `Struct`, a `Record` is immutable: its values
  # are set at construction and can never be changed. Divergence between the two
  # classes derive from this core difference.
  # 
  # ## Declaration
  # 
  # A `Record` class is declared in a manner identical to that used with Ruby's `Struct`.
  # The class method `new` is called with a list of one or more field names (symbols).
  # A new class will then be dynamically generated along with the necessary reader
  # attributes, one for each field. The newly created class will be anonymous and
  # will mixin `Functional::AbstractStruct`. The best practice is to assign the newly
  # created record class to a constant:
  # 
  # ```ruby
  # Customer = Functional::Record.new(:name, :address) #=> Customer
  # ```
  # 
  # Alternatively, the name of the record class, as a string, can be given as the
  # first parameter. In this case the new record class will be created as a constant
  # within the `Record` module:
  # 
  # ```ruby
  # Functional::Record.new("Customer", :name, :address) #=> Functional::Record::Customer
  # ```
  # 
  # **NOTE:** The `new` method of `Record` does not accept a block the way Ruby's `Struct`
  # does. The block passed to the `new` method of `Record` is used to set mandatory fields
  # and default values (see below). It is *not* used for additional class declarations.
  # 
  # ### Construction
  # 
  # Construction of a new object from a record is slightly different than for a Ruby `Struct`.
  # The constructor for a struct class may take zero or more field values and will use those
  # values to popuate the fields. The values passed to the constructor are assumed to be in
  # the same order as the fields were defined. This works for a struct because it is
  # mutable--the field values may be changed after instanciation. Therefore it is not
  # necessary to provide all values to a stuct at creation. This is not the case for a
  # record. A record is immutable. The values for all its fields must be set at instanciation
  # because they cannot be changed later. When creating a new record object the constructor
  # will accept a collection of field/value pairs in hash syntax and will create the new
  # record with the given values:
  # 
  # ```ruby
  # Customer.new(name: 'Dave', address: '123 Main')
  #  #=> #<record Customer :name=>"Dave", :address=>"123 Main">
  # 
  # Functional::Record::Customer.new(name: 'Dave', address: '123 Main')
  #  #=> #<record Functional::Record::Customer :name=>"Dave", :address=>"123 Main">
  # ```
  # 
  # ### Default Values
  # 
  # By default, all record fields are set to `nil` at instanciation unless explicity set
  # via the constructor. It is possible to specify default values other than `nil` for
  # zero or more of the fields when a new record class is created. The `new` method of
  # `Record` accepts a block which can be used to declare new default values:
  # 
  # ```ruby
  # Address = Functional::Record.new(:street_line_1, :street_line_2,
  #                                  :city, :state, :postal_code, :country) do
  #   default :state, 'Ohio'
  #   default :country, 'USA'
  # end
  #  #=> Address
  # ```
  # 
  # When a new object is created from a record class with explicit default values, those
  # values will be used for the appropriate fields when no other value is given at
  # construction:
  # 
  # ```ruby
  # Address.new(street_line_1: '2401 Ontario St',
  #             city: 'Cleveland', postal_code: 44115)
  #  #=> #<record Address :street_line_1=>"2401 Ontario St", :street_line_2=>nil, :city=>"Cleveland", :state=>"Ohio", :postal_code=>44115, :country=>"USA">
  # ```
  # 
  # Of course, if a value for a field is given at construction that value will be used instead
  # of the custom default:
  # 
  # ```ruby
  # Address.new(street_line_1: '1060 W Addison St',
  #             city: 'Chicago', state: 'Illinois', postal_code: 60613)
  #  #=> #<record Address :street_line_1=>"1060 W Addison St", :street_line_2=>nil, :city=>"Chicago", :state=>"Illinois", :postal_code=>60613, :country=>"USA">
  # ```
  # 
  # ### Mandatory Fields
  # 
  # By default, all record fields are optional. It is perfectly legal for a record
  # object to exist with all its fields set to `nil`. During declaration of a new record
  # class the block passed to `Record.new` can also be used to indicate which fields
  # are mandatory. When a new object is created from a record with mandatory fields
  # an exception will be thrown if any of those fields are nil:
  # 
  # ```ruby
  # Name = Functional::Record.new(:first, :middle, :last, :suffix) do
  #   mandatory :first, :last
  # end
  #  #=> Name
  # 
  # Name.new(first: 'Joe', last: 'Armstrong')
  #  #=> #<record Name :first=>"Joe", :middle=>nil, :last=>"Armstrong", :suffix=>nil>
  # 
  # Name.new(first: 'Matz') #=> ArgumentError: mandatory fields must not be nil
  # ```
  # 
  # Of course, declarations for default values and mandatory fields may be used
  # together:
  # 
  # ```ruby
  # Person = Functional::Record.new(:first_name, :middle_name, :last_name,
  #                                 :street_line_1, :street_line_2,
  #                                 :city, :state, :postal_code, :country) do
  #   mandatory :first_name, :last_name
  #   mandatory :country
  #   default :state, 'Ohio'
  #   default :country, 'USA'
  # end
  #  #=> Person
  # ```
  # 
  # ### Default Value Memoization
  # 
  # Note that the block provided to `Record.new` is processed once and only once
  # when the new record class is declared. Thereafter the results are memoized
  # and copied (via `clone`, unless uncloneable) each time a new record object
  # is created. Default values should be simple types like `String`, `Fixnum`,
  # and `Boolean`. If complex operations need performed when setting default
  # values the a `Class` should be used instead of a `Record`.
  # 
  # ## Inspiration
  # 
  # Neither struct nor records are new to computing. Both have been around for a very
  # long time. Mutable structs can be found in many languages including
  # [Ruby](http://www.ruby-doc.org/core-2.1.2/Struct.html),
  # [Go](http://golang.org/ref/spec#Struct_types),
  # [C](http://en.wikipedia.org/wiki/Struct_(C_programming_language)),
  # and [C#](http://msdn.microsoft.com/en-us/library/ah19swz4.aspx),
  # just to name a few. Immutable records exist primarily in functional languages
  # like [Haskell](http://en.wikibooks.org/wiki/Haskell/More_on_datatypes#Named_Fields_.28Record_Syntax.29),
  # Clojure, and Erlang. The latter two are the main influences for this implementation.
  # 
  # * [Ruby Struct](http://www.ruby-doc.org/core-2.1.2/Struct.html)
  # * [Clojure Datatypes](http://clojure.org/datatypes)
  # * [Clojure *defrecord* macro](http://clojure.github.io/clojure/clojure.core-api.html#clojure.core/defrecord)
  # * [Erlang Records (Reference)](http://www.erlang.org/doc/reference_manual/records.html)
  # * [Erlang Records (Examples)](http://www.erlang.org/doc/programming_examples/records.html)
  #
  # @see Functional::AbstractStruct
  # @see Functional::Union
  module Record
    extend self

    # Create a new record class with the given fields.
    #
    # @return [Functional::AbstractStruct] the new record subclass
    # @raise [ArgumentError] no fields specified
    def new(*fields, &block)
      raise ArgumentError.new('no fields provided') if fields.empty?
      build(fields, &block)
    end

    private

    # @!visibility private
    #
    # A set of restrictions governing the creation of a new record.
    class Restrictions
      include TypeCheck

      # Create a new restrictions object by processing the given
      # block. The block should be the DSL for defining a record class.
      def initialize(&block)
        @required = []
        @defaults = {}
        instance_eval(&block) if block_given?
        @required.freeze
        @defaults.freeze
        self.freeze
      end

      # DSL method for declaring one or more fields to be mandatory.
      #
      # @param [Symbol] fields zero or more mandatory fields
      def mandatory(*fields)
        @required.concat(fields.collect{|field| field.to_sym})
      end

      # DSL method for declaring a default value for a field
      #
      # @param [Symbol] field the field to be given a default value
      # @param [Object] value the default value of the field
      def default(field, value)
        @defaults[field] = value
      end

      # Clone a default value if it is cloneable. Else just return
      # the value.
      #
      # @param [Symbol] field the name of the field from which the
      #   default value is to be cloned.
      # @return [Object] a clone of the value or the value if uncloneable
      def clone_default(field)
        value = @defaults[field]
        value = value.clone unless uncloneable?(value)
      rescue TypeError
        # can't be cloned
      ensure
        return value
      end

      # Check the given data hash to see if it contains non-nil values for
      # all mandatory fields.
      #
      # @param [Hash] data the data hash
      # @raise [ArgumentError] if any mandatory fields are missing
      def check_mandatory!(data)
        if data.any?{|k,v| @required.include?(k) && v.nil? }
          raise ArgumentError.new('mandatory fields must not be nil')
        end
      end

      private

      # Is the given object uncloneable?
      #
      # @param [Object] object the object to check
      # @return [Boolean] true if the object cannot be cloned else false
      def uncloneable?(object)
        Type? object, NilClass, TrueClass, FalseClass, Fixnum, Bignum, Float
      end
    end

    # Use the given `AbstractStruct` class and build the methods necessary
    # to support the given data fields.
    #
    # @param [Array] fields the list of symbolic names for all data fields
    # @return [Functional::AbstractStruct] the record class
    def build(fields, &block)
      record, fields = define_class(fields)
      record.send(:datatype=, :record)
      record.send(:fields=, fields)
      record.class_variable_set(:@@restrictions, Restrictions.new(&block))
      define_initializer(record)
      fields.each do |field|
        define_reader(record, field)
      end
      record
    end

    # Define the new record class and, if necessary, register it with `Record`
    #
    # @param [Array] fields the list of symbolic names for all data fields
    # @return [Functional::AbstractStruct, Arrat] the new class and the
    #   (possibly) updated fields array
    def define_class(fields)
      record = Class.new{ include AbstractStruct }
      if fields.first.is_a? String
        self.const_set(fields.first, record)
        fields = fields[1, fields.length-1]
      end
      fields = fields.collect{|field| field.to_sym }.freeze
      [record, fields]
    end

    # Define an initializer method on the given record class.
    #
    # @param [Functional::AbstractStruct] record the new record class
    # @return [Functional::AbstractStruct] the record class
    def define_initializer(record)
      record.send(:define_method, :initialize) do |data = {}|
        restrictions = self.class.class_variable_get(:@@restrictions)
        data = fields.reduce({}) do |memo, field|
          memo[field] = data.fetch(field, restrictions.clone_default(field))
          memo
        end
        restrictions.check_mandatory!(data)
        set_data_hash(data)
        set_values_array(data.values)
        self.freeze
      end
      record
    end

    # Define a reader method on the given record class for the given data field.
    #
    # @param [Functional::AbstractStruct] record the new record class
    # @param [Symbol] field symbolic name of the current data field
    # @return [Functional::AbstractStruct] the record class
    def define_reader(record, field)
      record.send(:define_method, field) do
        to_h[field]
      end
      record
    end
  end
end
