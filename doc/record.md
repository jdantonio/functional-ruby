###    Declaration

   A `Record` class is declared in a manner identical to that used with Ruby's `Struct`.
   The class method `new` is called with a list of one or more field names (symbols).
   A new class will then be dynamically generated along with the necessary reader
   attributes, one for each field. The newly created class will be anonymous and
   will mixin `Functional::AbstractStruct`. The best practice is to assign the newly
   created record class to a constant:

   ```ruby
   Customer = Functional::Record.new(:name, :address) => Customer
   ```

   Alternatively, the name of the record class, as a string, can be given as the
   first parameter. In this case the new record class will be created as a constant
   within the `Record` module:

   ```ruby
   Functional::Record.new("Customer", :name, :address) => Functional::Record::Customer
   ```

###    Type Specification

   Unlike a Ruby `Struct`, a `Record` may be declared with a type/protocol
   specification. In this case, all data members are checked against the
   specification whenever a new record is created. Declaring a `Record` with a
   type specification is similar to declaring a normal `Record`, except that
   the field list is given as a hash with field names as the keys and a class or
   protocol as the values.

   ```ruby
   Functional::SpecifyProtocol(:Name) do
     attr_reader :first
     attr_reader :middle
     attr_reader :last
   end

   TypedCustomer = Functional::Record.new(name: :Name, address: String) => TypedCustomer

   Functional::Record.new("TypedCustomer", name: :Name, address: String) => Functional::Record::TypedCustomer
   ```

###    Construction

   Construction of a new object from a record is slightly different than for a Ruby `Struct`.
   The constructor for a struct class may take zero or more field values and will use those
   values to popuate the fields. The values passed to the constructor are assumed to be in
   the same order as the fields were defined. This works for a struct because it is
   mutable--the field values may be changed after instanciation. Therefore it is not
   necessary to provide all values to a stuct at creation. This is not the case for a
   record. A record is immutable. The values for all its fields must be set at instanciation
   because they cannot be changed later. When creating a new record object the constructor
   will accept a collection of field/value pairs in hash syntax and will create the new
   record with the given values:

   ```ruby
   Customer.new(name: 'Dave', address: '123 Main')
    => <record Customer :name=>"Dave", :address=>"123 Main">

   Functional::Record::Customer.new(name: 'Dave', address: '123 Main')
    => <record Functional::Record::Customer :name=>"Dave", :address=>"123 Main">
   ```

   When a record is defined with a type/protocol specification, the values of
   all non-nil data members are checked against the specification. Any data
   value that is not of the given type or does not satisfy the given protocol
   will cause an exception to be raised:

   ```ruby
   class Name
     attr_reader :first, :middle, :last
     def initialize(first, middle, last)
       @first = first
       @middle = middle
       @last = last
     end
   end

   name = Name.new('Douglas', nil, 'Adams') => <Name:0x007fc8b951a278 ...
   TypedCustomer.new(name: name, address: '123 Main') => <record TypedCustomer :name=><Name:0x007f914cce05b0 ...

   TypedCustomer.new(name: 'Douglas Adams', address: '123 Main') => ArgumentError: 'name' must stasify the protocol :Name
   TypedCustomer.new(name: name, address: 42) => ArgumentError: 'address' must be of type String
   ```

###    Default Values

   By default, all record fields are set to `nil` at instanciation unless explicity set
   via the constructor. It is possible to specify default values other than `nil` for
   zero or more of the fields when a new record class is created. The `new` method of
   `Record` accepts a block which can be used to declare new default values:

   ```ruby
   Address = Functional::Record.new(:street_line_1, :street_line_2,
                                    :city, :state, :postal_code, :country) do
     default :state, 'Ohio'
     default :country, 'USA'
   end
    => Address
   ```

   When a new object is created from a record class with explicit default values, those
   values will be used for the appropriate fields when no other value is given at
   construction:

   ```ruby
   Address.new(street_line_1: '2401 Ontario St',
               city: 'Cleveland', postal_code: 44115)
    => <record Address :street_line_1=>"2401 Ontario St", :street_line_2=>nil, :city=>"Cleveland", :state=>"Ohio", :postal_code=>44115, :country=>"USA">
   ```

   Of course, if a value for a field is given at construction that value will be used instead
   of the custom default:

   ```ruby
   Address.new(street_line_1: '1060 W Addison St',
               city: 'Chicago', state: 'Illinois', postal_code: 60613)
    => <record Address :street_line_1=>"1060 W Addison St", :street_line_2=>nil, :city=>"Chicago", :state=>"Illinois", :postal_code=>60613, :country=>"USA">
   ```

###    Mandatory Fields

   By default, all record fields are optional. It is perfectly legal for a record
   object to exist with all its fields set to `nil`. During declaration of a new record
   class the block passed to `Record.new` can also be used to indicate which fields
   are mandatory. When a new object is created from a record with mandatory fields
   an exception will be thrown if any of those fields are nil:

   ```ruby
   Name = Functional::Record.new(:first, :middle, :last, :suffix) do
     mandatory :first, :last
   end
    => Name

   Name.new(first: 'Joe', last: 'Armstrong')
    => <record Name :first=>"Joe", :middle=>nil, :last=>"Armstrong", :suffix=>nil>

   Name.new(first: 'Matz') => ArgumentError: mandatory fields must not be nil
   ```

   Of course, declarations for default values and mandatory fields may be used
   together:

   ```ruby
   Person = Functional::Record.new(:first_name, :middle_name, :last_name,
                                   :street_line_1, :street_line_2,
                                   :city, :state, :postal_code, :country) do
     mandatory :first_name, :last_name
     mandatory :country
     default :state, 'Ohio'
     default :country, 'USA'
   end
    => Person
   ```

###    Default Value Memoization

   Note that the block provided to `Record.new` is processed once and only once
   when the new record class is declared. Thereafter the results are memoized
   and copied (via `clone`, unless uncloneable) each time a new record object
   is created. Default values should be simple types like `String`, `Fixnum`,
   and `Boolean`. If complex operations need performed when setting default
   values the a `Class` should be used instead of a `Record`.

#####    Why Declaration Differs from Ruby's Struct

   Those familiar with Ruby's `Struct` class will notice one important
   difference when declaring a `Record`: the block passes to `new` cannot be
   used to define additional methods. When declaring a new class created from a
   Ruby `Struct` the block can perform any additional class definition that
   could be done had the class be defined normally. The excellent
   [Values](https://github.com/tcrayford/Values) supports this same behavior.
   `Record` does not allow additional class definitions during declaration for
   one simple reason: doing so violates two very important tenets of functional
   programming. Specifically, immutability and the separation of data from
   operations.

   `Record` exists for the purpose of creating immutable objects. If additional
   instance methods were to be defined on a record class it would be possible
   to violate immutability. Not only could additional, mutable state be added
   to the class, but the existing immutable attributes could be overridden by
   mutable methods. The security of providing an immutable object would be
   completely shattered, thus defeating the original purpose of the record
   class. Of course it would be possible to allow this feature and trust the
   programmer to not violate the intended immutability of class, but opening
   `Record` to the *possibility* of immutability violation is unnecessary and
   unwise.

   More important than the potential for immutability violations is the fact
   the adding additional methods to a record violates the principal of
   separating data from operations on that data. This is one of the core ideas
   in functional programming. Data is defined in pure structures that contain
   no behavior and operations on that data are provided by polymorphic
   functions. This may seem counterintuitive to object oriented programmers,
   but that is the nature of functional programming. Adding behavior to a
   record, even when that behavior does not violate immutability, is still
   anathema to functional programming, and it is why records in languages like
   Erlang and Clojure do not have functions defined within them.

   Should additional methods need defined on a `Record` class, the appropriate
   practice is to declare the record class then declare another class which
   extends the record. The record class remains pure data and the subclass
   contains additional operations on that data.

   ```ruby
   NameRecord = Functional::Record.new(:first, :middle, :last, :suffix) do
     mandatory :first, :last
   end

   class Name < NameRecord
     def full_name
       "{first} {last}"
     end

     def formal_name
       name = [first, middle, last].select{|s| ! s.to_s.empty?}.join(' ')
       suffix.to_s.empty? ? name : name + ", {suffix}"
     end
   end

   jerry = Name.new(first: 'Jerry', last: "D'Antonio")
   ted   = Name.new(first: 'Ted', middle: 'Theodore', last: 'Logan', suffix: 'Esq.')

   jerry.formal_name => "Jerry D'Antonio"
   ted.formal_name   => "Ted Theodore Logan, Esq."
   ```

###    Inspiration

   Neither struct nor records are new to computing. Both have been around for a very
   long time. Mutable structs can be found in many languages including
   [Ruby](http://www.ruby-doc.org/core-2.1.2/Struct.html),
   [Go](http://golang.org/ref/specStruct_types),
   [C](http://en.wikipedia.org/wiki/Struct_(C_programming_language)),
   and [C](http://msdn.microsoft.com/en-us/library/ah19swz4.aspx),
   just to name a few. Immutable records exist primarily in functional languages
   like [Haskell](http://en.wikibooks.org/wiki/Haskell/More_on_datatypesNamed_Fields_.28Record_Syntax.29),
   Clojure, and Erlang. The inspiration for declaring records with a type
   specification is taken from [PureScript](http://www.purescript.org/), a
   compile-to-JavaScript language inspired by Haskell.

   * [Ruby Struct](http://www.ruby-doc.org/core-2.1.2/Struct.html)
   * [Clojure Datatypes](http://clojure.org/datatypes)
   * [Clojure *defrecord* macro](http://clojure.github.io/clojure/clojure.core-api.htmlclojure.core/defrecord)
   * [Erlang Records (Reference)](http://www.erlang.org/doc/reference_manual/records.html)
   * [Erlang Records (Examples)](http://www.erlang.org/doc/programming_examples/records.html)
   * [PureScript Records](http://docs.purescript.org/en/latest/types.htmlrecords)
