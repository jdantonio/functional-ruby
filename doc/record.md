An immutable data structure with multiple data fields. A `Record` is a
convenient way to bundle a number of field attributes together,
using accessor methods, without having to write an explicit class.
The `Record` module generates new `AbstractStruct` subclasses that hold a
set of fields with a reader method for each field.

A `Record` is very similar to a Ruby `Struct` and shares many of its behaviors
and attributes. Unlike a # Ruby `Struct`, a `Record` is immutable: its values
are set at construction and can never be changed. Divergence between the two
classes derive from this core difference.

## Declaration


## Default Values


## Mandatory Fields

## Inspiration

Neither struct nor records are new to computing. Both have been around for a very
long time. Mutable structs can be found in many languages including
[Ruby](http://www.ruby-doc.org/core-2.1.2/Struct.html),
[Go](http://golang.org/ref/spec#Struct_types),
[C](http://en.wikipedia.org/wiki/Struct_(C_programming_language)),
and [C#](http://msdn.microsoft.com/en-us/library/ah19swz4.aspx),
just to name a few. Immutable records exist primarily in functional languages
like [Haskell](http://en.wikibooks.org/wiki/Haskell/More_on_datatypes#Named_Fields_.28Record_Syntax.29),
Clojure, and Erlang. The latter two are the main influences for this implementation.

* [Ruby Struct](http://www.ruby-doc.org/core-2.1.2/Struct.html)
* [Clojure Datatypes](http://clojure.org/datatypes)
* [Clojure *defrecord* macro](http://clojure.github.io/clojure/clojure.core-api.html#clojure.core/defrecord)
* [Erlang Records (Reference)](http://www.erlang.org/doc/reference_manual/records.html)
* [Erlang Records (Examples)](http://www.erlang.org/doc/programming_examples/records.html)
