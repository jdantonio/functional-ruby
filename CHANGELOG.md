## Current Release v1.1.0 (August 12, 2014)

* A simple implementation of [tuple](http://en.wikipedia.org/wiki/Tuple), an
  immutable, fixed-length list/array/vector-like data structure.
* `FinalStruct`, a variation on Ruby's `OpenStruct` in which all fields are "final" (meaning
  that new fields can be arbitrarily added but once set each field becomes immutable).
* `FinalVar`, a thread safe object that holds a single value and is "final" (meaning
  that the value can be set at most once after which it becomes immutable).

### Previous Release v1.0.0 (July 30, 2014)

* Protocol specifications inspired by Clojure [protocol](http://clojure.org/protocols),
  Erlang [behavior](http://www.erlang.org/doc/design_principles/des_princ.html#id60128),
  and Objective-C [protocol](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html)
* Function overloading with Erlang-style [function](http://erlang.org/doc/reference_manual/functions.html)
  [pattern matching](http://erlang.org/doc/reference_manual/patterns.html)
* Simple, immutable data structures, such as *record* and *union*, inspired by
  [Clojure](http://clojure.org/datatypes), [Erlang](http://www.erlang.org/doc/reference_manual/records.html),
  and [others](http://en.wikipedia.org/wiki/Union_type)
* `Either` and `Option` classes based on [Functional Java](http://functionaljava.org/) and [Haskell](https://hackage.haskell.org/package/base-4.2.0.1/docs/Data-Either.html)
* [Memoization](http://en.wikipedia.org/wiki/Memoization) of class methods based on Clojure [memoize](http://clojuredocs.org/clojure_core/clojure.core/memoize)
* Lazy execution with a `Delay` class based on Clojure [delay](http://clojuredocs.org/clojure_core/clojure.core/delay)
