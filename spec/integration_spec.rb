require 'spec_helper'
require 'ostruct'

  class Bar
    def greet
      return 'Hello, World!'
    end
  end

  class Foo < Bar
    include PatternMatching

    attr_accessor :name

    defn(:initialize) { @name = 'baz' }
    defn(:initialize, _) {|name| @name = name.to_s }

    defn(:greet, _) do |name|
      "Hello, #{name}!"
    end

    defn(:greet, :male, _) { |name|
      "Hello, Mr. #{name}!"
    }
    defn(:greet, :female, _) { |name|
      "Hello, Ms. #{name}!"
    }
    defn(:greet, nil, _) { |name|
      "Goodbye, #{name}!"
    }
    defn(:greet, _, _) { |_, name|
      "Hello, #{name}!"
    }

    defn(:hashable, _, {foo: :bar}, _) { |_, opts, _|
      :foo_bar
    }
    defn(:hashable, _, {foo: _, bar: _}, _) { |_, f, b, _|
      [f, b]
    }
    defn(:hashable, _, {foo: _}, _) { |_, f, _|
      f
    }
    defn(:hashable, _, {}, _) {
      :empty
    }
    defn(:hashable, _, _, _) { |_, _, _|
      :unbound
    }

    defn(:options, _) { |opts|
      opts
    }

    defn(:recurse) {
      'w00t!'
    }
    defn(:recurse, :match) {
      recurse()
    }
    defn(:recurse, :super) {
      greet()
    }
    defn(:recurse, :instance) {
      @name
    }
    defn(:recurse, _) { |arg|
      arg
    }

    defn(:concat, Integer, Integer) { |first, second|
      first + second
    }
    defn(:concat, Integer, String) { |first, second|
      "#{first} #{second}"
    }
    defn(:concat, String, String) { |first, second|
      first + second
    }
    defn(:concat, Integer, UNBOUND) { |first, second|
      first + second.to_i
    }

    defn(:all, :one, ALL) { |args|
      args
    }
    defn(:all, :one, Integer, ALL) { |int, args|
      [int, args]
    }
    defn(:all, 1, _, ALL) { |var, args|
      [var, args]
    }
    defn(:all, ALL) { | args|
      args
    }

    defn(:old_enough, _){ true }.when{|x| x >= 16 }
    defn(:old_enough, _){ false }

    defn(:right_age, _) {
      true
    }.when{|x| x >= 16 && x <= 104 }

    defn(:right_age, _) {
      false
    }

    defn(:wrong_age, _) {
      true
    }.when{|x| x < 16 || x > 104 }

    defn(:wrong_age, _) {
      false
    }
  end

  class Baz < Foo
    def boom_boom_room
      'zoom zoom zoom'
    end
    def who(first, last)
      [first, last].join(' ')
    end
  end

  class Fizzbuzz < Baz
    include PatternMatching
    defn(:who, Integer) { |count|
      (1..count).each.reduce(:+)
    }
    defn(:who) { 0 }
  end

describe 'integration' do

  let(:name) { 'Pattern Matcher' }
  subject { Foo.new(name) }

  specify { subject.greet.should eq 'Hello, World!' }

  specify { subject.greet('Jerry').should eq 'Hello, Jerry!' }

  specify { subject.greet(:male, 'Jerry').should eq 'Hello, Mr. Jerry!' }
  specify { subject.greet(:female, 'Jeri').should eq 'Hello, Ms. Jeri!' }
  specify { subject.greet(:unknown, 'Jerry').should eq 'Hello, Jerry!' }
  specify { subject.greet(nil, 'Jerry').should eq 'Goodbye, Jerry!' }
  specify {
    lambda { Foo.new.greet(1,2,3,4,5,6,7) }.should raise_error(NoMethodError)
  }

  specify { subject.options(bar: :baz, one: 1, many: 2).should == {bar: :baz, one: 1, many: 2} }

  specify { subject.hashable(:male, {foo: :bar}, :female).should eq :foo_bar }
  specify { subject.hashable(:male, {foo: :baz}, :female).should eq :baz }
  specify { subject.hashable(:male, {foo: 1, bar: 2}, :female).should eq [1, 2] }
  specify { subject.hashable(:male, {foo: 1, baz: 2}, :female).should eq 1 }
  specify { subject.hashable(:male, {bar: :baz}, :female).should eq :unbound }
  specify { subject.hashable(:male, {}, :female).should eq :empty }

  specify { subject.recurse.should eq 'w00t!' }
  specify { subject.recurse(:match).should eq 'w00t!' }
  specify { subject.recurse(:super).should eq 'Hello, World!' }
  specify { subject.recurse(:instance).should eq name }
  specify { subject.recurse(:foo).should eq :foo }

  specify { subject.concat(1, 1).should eq 2 }
  specify { subject.concat(1, 'shoe').should eq '1 shoe' }
  specify { subject.concat('shoe', 'fly').should eq 'shoefly' }
  specify { subject.concat(1, 2.9).should eq 3 }

  specify { subject.all(:one, 'a', 'bee', :see).should == ['a', 'bee', :see] }
  specify { subject.all(:one, 1, 'bee', :see).should == [1, 'bee', :see] }
  specify { subject.all(1, 'a', 'bee', :see).should == ['a', ['bee', :see]] }
  specify { subject.all('a', 'bee', :see).should == ['a', 'bee', :see] }
  specify { lambda { subject.all }.should raise_error(NoMethodError) }

  specify { subject.old_enough(20).should be_true }
  specify { subject.old_enough(10).should be_false }

  specify { subject.right_age(20).should be_true }
  specify { subject.right_age(10).should be_false }
  specify { subject.right_age(110).should be_false }

  specify { subject.wrong_age(20).should be_false }
  specify { subject.wrong_age(10).should be_true }
  specify { subject.wrong_age(110).should be_true }

  context 'inheritance' do

    specify { Fizzbuzz.new.greet(:male, 'Jerry').should eq 'Hello, Mr. Jerry!' }
    specify { Fizzbuzz.new.greet(:female, 'Jeri').should eq 'Hello, Ms. Jeri!' }
    specify { Fizzbuzz.new.greet(:unknown, 'Jerry').should eq 'Hello, Jerry!' }
    specify { Fizzbuzz.new.greet(nil, 'Jerry').should eq 'Goodbye, Jerry!' }

    specify { Fizzbuzz.new.who(5).should eq 15 }
    specify { Fizzbuzz.new.who().should eq 0 }
    specify { 
      lambda {
        Fizzbuzz.new.who('Jerry', "D'Antonio")
      }.should raise_error(NoMethodError)
    }

    specify { Fizzbuzz.new.boom_boom_room.should eq 'zoom zoom zoom' }
  end
end
