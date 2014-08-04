module Functional

  # An exception raised when an attempt is made to modify an
  # immutable object or attribute.
  FinalityError = Class.new(StandardError)

  # Functions for supporting immutability inspired by Java's `final` keyword.
  #
  # Immutability is an important aspect of functional programming, but many
  # immutable data structures, such as {Functional::Record}, require all accessor
  # fields to be set on object creation. The `final` keyword in Java allows
  # various constructs to be declared "write once." These constructs initially
  # have no value. They can be given a value once, after which they become
  # immutable.
  #
  # # #final_attribute
  #
  # The `final_attribute` function is a variant of Ruby's `attr_accessor` that
  # allows an attribute to be written at most once but read an unlimited number
  # of times. It is based on Java's `public final` variable idiom. To declare
  # a final attribute, simply include the `Functional::Final` module in a class
  # then declare one or more final attributes:
  #
  # ```ruby
  # class Foo
  #   include Functional::Final
  #   final_attribute :bar
  # end
  # ```
  # This will cause several instance methods to be defined: a reader, a writer,
  # a predicate, and a "try" writer.
  #
  # ### Attribute Reader
  #
  # The reader method of a final attribute can be called any number of times.
  # Initially it will return `nil` because the attribute has not been set. Once
  # the attribute has been set using the writer method, the reader method will
  # return the new value.
  #
  # ```ruby
  # foo = Foo.new
  # foo.bar      #=> nil
  # foo.bar = 42 #=> 42
  # foo.bar      #=> 42
  # ```
  #
  # ### Attribute Writer
  #
  # The write method of a final attribute can be called no more than once. When
  # called it will set the value of the attribute to the given value (`nil` is
  # a valid value). Once set the reader method will forever return the new value.
  # It is a logical error to attempt to write a final attribute more than once.
  # The second and subsequent call to the writer of a final attribute will
  # result in a {Functional::FinalityError} being raised.
  #
  # ```ruby
  # foo = Foo.new
  # foo.bar = 42 #=> 42
  # foo.bar      #=> 42
  # foo.bar = 42 #=> Functional::FinalityError: final accessor 'bar' has already been set
  # ```
  #
  # The return value of the attribute writer method, when successful, is the new value.
  # This behavior is consistent with writer methods created using Ruby's
  # `attr_accessor` method.
  #
  # ### Attribute Predicate
  #
  # Knowing whether or not a final attribute has been set is important. The predicate
  # method of a final attribute can be used to determine if the value has been set.
  # When the value of the attribute has been set the predicate will return `true`.
  # When the value has not been set the predicate will return `false`.
  #
  # ```ruby
  # foo = Foo.new
  # foo.bar?     #=> false
  # foo.bar = 42 #=> 42
  # foo.bar?     #=> true
  # ```
  #
  # Note that the predicate method passes no judgement on the *value* of the attribute.
  # When the attribute has been set to a "falsey" value such as `false` or `nil` the
  # predicate will still return `true`. Since `nil` is a valid value for a final attribute
  # the attribute reader should never be checked for `nil` as a way of determining if
  # the value has been set. Always use the predicate.
  #
  # ## Inspiration
  #
  # * [Java's `final` keyword](http://en.wikipedia.org/wiki/Final_(Java))
  #
  # @since 1.1.0
  module Final

    # @!visibility private
    def self.included(base)
      base.extend(ClassMethods)
      super(base)
    end

    # Raise an error indicating that the final attribute with the given
    # name has already been set
    #
    # @param [Symbol] name the name of the first attribute causing the error
    # @raise [Functional::FinalityError] with an appropriate message
    #
    # @!visibility private
    def raise_final_attr_already_set_error(name)
      raise FinalityError.new("final accessor '#{name}' has already been set")
    end
    module_function :raise_final_attr_already_set_error

    # @!visibility private
    module ClassMethods

      # A variant of Ruby's `attr_accessor` that allows an attribute to be written
      # to at most once but read an unlimited number of times. Based on Java's
      # `public final` variable idiom.
      #
      # @param [Symbol] name the name of the first attribute to create
      # @param [Symbol] names the names of additional attributes to create
      #
      # @see http://www.ruby-doc.org/core-2.1.2/Module.html#method-i-attr_accessor attr_accessor
      # @see http://en.wikipedia.org/wiki/Final_(Java) final (Java) at Wikipedia
      def final_attribute(name, *names)
        (names << name).each do |func|
          define_unset_final_attribute(func)
        end
        nil
      end

      protected

      # Define the class methods for an unset final attribute.
      #
      # @param [Symbol] name the name of the first attribute to create
      #
      # @!visibility private
      def define_unset_final_attribute(name)
        send(:define_method, name){ nil }
        send(:define_method, "#{name}?"){ false }
        send(:define_method, "#{name}="){|value|
          singleton_class.send(:define_set_final_attribute, name, value)
        }
        name.to_sym
      end

      # Define the class/instance/singleton methods for a set final attribute.
      #
      # @param [Symbol] name the name of the first attribute to create
      # @param [Object] value the value to set the attribute to
      # @param [Boolean] define_writer will define a final writer method when true
      #
      # @!visibility private
      def define_set_final_attribute(name, value, define_writer = true)
        # Each of the following method calls is atomic, but they are not atomic as a group.
        # Wrapping all three method calls in an atomic block would be very difficult
        # (if not impossible) given that 1) this is a mixin module and 2) Ruby lacks a memory model.
        # Since calling this method more than once is a logical error that raises an exception,
        # the following call order will provide the expected behavior when used properly.
        send(:define_method, "#{name}?"){ true }
        send(:define_method, "#{name}=") {|value|
          raise_final_attr_already_set_error(name)
        } if define_writer
        send(:define_method, name){ value }
        value
      end
    end
  end
end
