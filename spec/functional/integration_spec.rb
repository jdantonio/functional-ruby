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

  specify { expect(subject.greet).to eq 'Hello, World!' }

  specify { expect(subject.greet('Jerry')).to eq 'Hello, Jerry!' }

  specify { expect(subject.greet(:male, 'Jerry')).to eq 'Hello, Mr. Jerry!' }
  specify { expect(subject.greet(:female, 'Jeri')).to eq 'Hello, Ms. Jeri!' }
  specify { expect(subject.greet(:unknown, 'Jerry')).to eq 'Hello, Jerry!' }
  specify { expect(subject.greet(nil, 'Jerry')).to eq 'Goodbye, Jerry!' }
  specify {
    expect { Foo.new.greet(1,2,3,4,5,6,7) }.to raise_error(NoMethodError)
  }

  specify { expect(subject.options(bar: :baz, one: 1, many: 2)).to eq({bar: :baz, one: 1, many: 2}) }

  specify { expect(subject.hashable(:male, {foo: :bar}, :female)).to eq :foo_bar }
  specify { expect(subject.hashable(:male, {foo: :baz}, :female)).to eq :baz }
  specify { expect(subject.hashable(:male, {foo: 1, bar: 2}, :female)).to eq [1, 2] }
  specify { expect(subject.hashable(:male, {foo: 1, baz: 2}, :female)).to eq 1 }
  specify { expect(subject.hashable(:male, {bar: :baz}, :female)).to eq :unbound }
  specify { expect(subject.hashable(:male, {}, :female)).to eq :empty }

  specify { expect(subject.recurse).to eq 'w00t!' }
  specify { expect(subject.recurse(:match)).to eq 'w00t!' }
  specify { expect(subject.recurse(:super)).to eq 'Hello, World!' }
  specify { expect(subject.recurse(:instance)).to eq name }
  specify { expect(subject.recurse(:foo)).to eq :foo }

  specify { expect(subject.concat(1, 1)).to eq 2 }
  specify { expect(subject.concat(1, 'shoe')).to eq '1 shoe' }
  specify { expect(subject.concat('shoe', 'fly')).to eq 'shoefly' }
  specify { expect(subject.concat(1, 2.9)).to eq 3 }

  specify { expect(subject.all(:one, 'a', 'bee', :see)).to eq(['a', 'bee', :see]) }
  specify { expect(subject.all(:one, 1, 'bee', :see)).to eq([1, 'bee', :see]) }
  specify { expect(subject.all(1, 'a', 'bee', :see)).to eq(['a', ['bee', :see]]) }
  specify { expect(subject.all('a', 'bee', :see)).to eq(['a', 'bee', :see]) }
  specify { expect { subject.all }.to raise_error(NoMethodError) }

  specify { expect(subject.old_enough(20)).to be true }
  specify { expect(subject.old_enough(10)).to be false }

  specify { expect(subject.right_age(20)).to be true }
  specify { expect(subject.right_age(10)).to be false }
  specify { expect(subject.right_age(110)).to be false }

  specify { expect(subject.wrong_age(20)).to be false }
  specify { expect(subject.wrong_age(10)).to be true }
  specify { expect(subject.wrong_age(110)).to be true }

  context 'inheritance' do

    specify { expect(Fizzbuzz.new.greet(:male, 'Jerry')).to eq 'Hello, Mr. Jerry!' }
    specify { expect(Fizzbuzz.new.greet(:female, 'Jeri')).to eq 'Hello, Ms. Jeri!' }
    specify { expect(Fizzbuzz.new.greet(:unknown, 'Jerry')).to eq 'Hello, Jerry!' }
    specify { expect(Fizzbuzz.new.greet(nil, 'Jerry')).to eq 'Goodbye, Jerry!' }

    specify { expect(Fizzbuzz.new.who(5)).to eq 15 }
    specify { expect(Fizzbuzz.new.who()).to eq 0 }
    specify { 
      expect {
        Fizzbuzz.new.who('Jerry', 'secret middle name', "D'Antonio")
      }.to raise_error(NoMethodError)
    }

    specify { expect(Fizzbuzz.new.boom_boom_room).to eq 'zoom zoom zoom' }
  end
end
