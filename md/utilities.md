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

repeatedly(10, 1){|previous| previous * 2 } #=> [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
```

## Copyright

*Functional Ruby* is Copyright &copy; 2013 [Jerry D'Antonio](https://twitter.com/jerrydantonio).
It is free software and may be redistributed under the terms specified in the LICENSE file.

## License

Released under the MIT license.

http://www.opensource.org/licenses/mit-license.php  

> Permission is hereby granted, free of charge, to any person obtaining a copy  
> of this software and associated documentation files (the "Software"), to deal  
> in the Software without restriction, including without limitation the rights  
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
> copies of the Software, and to permit persons to whom the Software is  
> furnished to do so, subject to the following conditions:  
> 
> The above copyright notice and this permission notice shall be included in  
> all copies or substantial portions of the Software.  
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  
> THE SOFTWARE.  
