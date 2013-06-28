# Promises, promises...

> A promise represents the eventual value returned from the single completion of an operation.

Promises have become an extremely important async technique in JavaScript. A promise is an
an operation that is performed asynchronously and is guaranteed to either succeed and return
a value or fail with a reason. What makes promises distinctly different from futures is
that promises can be chained such that the result of onw promise is passed to zero or
more children. Order of execution is guaranteed based on the order the promises are
created and parent promises are guaranteed to be complete before their children. Once a
promise has been fulfilled or rejected the corresponding value/reason can be retrieved.

## The shoulders of Giants

Inspiration for this implementation came from the CommonJS
[Promises/A](http://wiki.commonjs.org/wiki/Promises/A) proposal and the
[Promises/A+](http://promises-aplus.github.io/promises-spec/) specification.
This implementation is specifically tailored to the idioms and practices of
Ruby. It is not 100% compliant with either of the aforementioned specifications.

## Usage


Start by requiring promises

```ruby
require 'functional/promise'
```

Then create one

```ruby
p = Promise.new("Jerry", "D'Antonio") do |first, last|
      "#{last}, #{first}"
    end

# -or-

p = promise(10){|x| x * x * x }
```

Promises can be chained using the `then` method. The `then` method
accepts a block but no arguments. The result of the each promise is
passed as the block argument to chained promises


```ruby
p = promise(10){|x| x * 2}.then{|result| result - 10 }
```

And so on, and so on, and so on...

```ruby
p = promise(10){|x| x * 2}.
    then{|result| result - 10 }.
    then{|result| result * 3 }.
    then{|result| result % 5 }
```

Promises are executed asynchronously so a newly-created promise
*should* always be in the pending state


```ruby
p = promise{ "Hello, world!" }
p.state   #=> :pending
p.pending? #=> true
```

Wait a little bit, and the promise will resolve and provide a value


```ruby
p = promise{ "Hello, world!" }
sleep(0.1)

p.state      #=> :fulfilled
p.fulfilled? #=> true

p.value      #=> "Hello, world!"

```

If an exception occurs, the promise will be rejected and will provide
a reason for the rejection


```ruby
p = promise{ raise StandardError.new("Here comes the Boom!") }
sleep(0.1)

p.state     #=> :rejected
p.rejected? #=> true

p.reason=>  #=> "#<StandardError: Here comes the Boom!>"
```

### Rejection

Much like the economy, rejection exhibits a trickle-down effect. When
a promise is rejected all its children will be rejected

```ruby
p = [ promise{ sleep(1); raise StandardError } ]

10.times{|i| p << p.first.then{ i } }
sleep(0.1)

p.first.state #=> :rejected
p.last.state  #=> :rejected
```

Once a promise is rejected it will not accept any children. Calls
to `then` will continually return `self`

```ruby
p = promise{ raise StandardError }
sleep(0.1)

p.object_id        #=> 32960556
p.then{}.object_id #=> 32960556
p.then{}.object_id #=> 32960556
```

### Error Handling

Promises support error handling callbacks is a style mimicing Ruby's
own exception handling mechanism, namely `rescue`


```ruby
promise{ "dangerous operation..." }.rescue{|ex| puts "Bam!" }

# -or- (for the Java/C# crowd)
promise{ "dangerous operation..." }.catch{|ex| puts "Boom!" }

# -or- (for the hipsters)
promise{ "dangerous operation..." }.on_error{|ex| puts "Pow!" }
```

As with Ruby's `rescue` mechanism, a promise's `rescue` method can
accept an optional Exception class argument (defaults to `Exception`
when not specified)


```ruby
promise{ "dangerous operation..." }.rescue(ArgumentError){|ex| puts "Bam!" }
```

Calls to `rescue` can also be chained

```ruby
promise{ "dangerous operation..." }.
  rescue(ArgumentError){|ex| puts "Bam!" }.
  rescue(NoMethodError){|ex| puts "Boom!" }.
  rescue(StandardError){|ex| puts "Pow!" }
```

When there are multiple `rescue` handlers the first one to match the thrown
exception will be triggered

```ruby
promise{ raise NoMethodError }.
  rescue(ArgumentError){|ex| puts "Bam!" }.
  rescue(NoMethodError){|ex| puts "Boom!" }.
  rescue(StandardError){|ex| puts "Pow!" }

sleep(0.1)

#=> Boom!
```

If a promise does not have a matching `rescue` handlers the exception
will bubble up through the parents until one matches or the root promise
is reached

```ruby
promise{ "Hello" }.
  rescue(ArgumentError){|ex| puts "Bam!" }.
  rescue(NoMethodError){|ex| puts "Boom!" }.
  rescue(StandardError){|ex| puts "Pow!" }.
  then{|result| "#{result}, world!" }.
  then{ raise ArgumentError }

sleep(0.1)

#=> Bom!
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
