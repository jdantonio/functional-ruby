# Utility Functions

Convenience functions are not imported by default. They need a separate `require` statement:

```ruby
require 'functional/utilities'
```

This gives you access to a few constants and functions:

```ruby
Infinity #=> Infinity
NaN #=> NaN

repl? #=> true when called under irb, pry, bundle console, or rails console

safe(1, 2){|a, b| a + b} #=> 3
safe{ eval 'puts "Hello World!"' } #=> SecurityError: Insecure operation

pp_s [1,2,3,4] #=> "[1, 2, 3, 4]\n" props to Rha7

delta(-1, 1) #=> 2
delta({count: -1}, {count: 1}){|item| item[:count]} #=> 2
```
