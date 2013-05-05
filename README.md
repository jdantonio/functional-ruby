# PatternMatching [![Build Status](https://secure.travis-ci.org/jdantonio/pattern_matching.png)](http://travis-ci.org/jdantonio/pattern_matching?branch=master) [![Dependency Status](https://gemnasium.com/jdantonio/pattern_matching.png)](https://gemnasium.com/jdantonio/pattern_matching)

A gem for adding Erlang-style pattern matching to Ruby.

## Examples

For more examples see the integration tests in *spec/integration_spec.rb*.

### Simple Function

This example is based on [Syntax in defnctions: Pattern Matching](http://learnyousomeerlang.com/syntax-in-defnctions) in [Learn You Some Erlang for Great Good!](http://learnyousomeerlang.com/).

Erlang:

    greet(male, Name) ->
      io:format("Hello, Mr. ~s!", [Name]);
    greet(female, Name) ->
      io:format("Hello, Mrs. ~s!", [Name]);
    greet(_, Name) ->
      io:format("Hello, ~s!", [Name]).

Ruby:

    defn(:greet, _) do |name|
      "Hello, #{name}!"
    end

    defn(:greet, :male, _) { |name|
      "Hello, Mr. #{name}!"
    }
    defn(:greet, :female, _) { |name|
      "Hello, Ms. #{name}!"
    }
    defn(:greet, _, _) { |_, name|
      "Hello, #{name}!"
    }

### Simple Function with Overloading

This example is based on [Syntax in defnctions: Pattern Matching](http://learnyousomeerlang.com/syntax-in-defnctions) in [Learn You Some Erlang for Great Good!](http://learnyousomeerlang.com/).

Erlang:

    greet(Name) ->
      io:format("Hello, ~s!", [Name]).

    greet(male, Name) ->
      io:format("Hello, Mr. ~s!", [Name]);
    greet(female, Name) ->
      io:format("Hello, Mrs. ~s!", [Name]);
    greet(_, Name) ->
      io:format("Hello, ~s!", [Name]).

Ruby:

    defn(:greet, _) do |name|
      "Hello, #{name}!"
    end

    defn(:greet, :male, _) { |name|
      "Hello, Mr. #{name}!"
    }
    defn(:greet, :female, _) { |name|
      "Hello, Ms. #{name}!"
    }
    defn(:greet, _, _) { |_, name|
      "Hello, #{name}!"
    }

### Matching a Hash Parameter

Ruby:

    defn(:hashable, {foo: :bar}) { |opts|
      # matches any hash with key :foo and value :bar
      :foo_bar
    }
    defn(:hashable, {foo: _}) { |opts|
      # matches any hash with :key foo regardless of value
      :foo_unbound
    }
    defn(:hashable, {}) { |opts|
      # matches any hash
      :unbound_unbound
    }
