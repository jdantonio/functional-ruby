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


  end
end
