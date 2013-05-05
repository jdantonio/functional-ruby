# PatternMatching

A gem for adding Erlang-style pattern matching to Ruby.

## Examples

Some examples are taked from [Syntax in defnctions: Pattern Matching](http://learnyousomeerlang.com/syntax-in-defnctions). in [Learn You Some Erlang for Great Good!](http://learnyousomeerlang.com/). Others are unique to this README.

### Simple Function

Erlang:

    greet(male, Name) ->
      io:format("Hello, Mr. ~s!", [Name]);
    greet(female, Name) ->
      io:format("Hello, Mrs. ~s!", [Name]);
    greet(_, Name) ->
      io:format("Hello, ~s!", [Name]).

Ruby:

    defn greet(:male, name) {
      puts "Hello, Mr. #{name}!"
    }
    defn greet(:female, name) {
      puts "Hello, Ms. #{name}!"
    }
    defn greet(_, name) {
      puts "Hello, Ms. #{name}!"
    }

### Simple Function with Overloading


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
