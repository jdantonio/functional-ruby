require 'spec_helper'
require 'ostruct'

describe 'integration' do

  class Bar

    def greet
      return 'Hello, World!'
    end
  end

  class Foo < Bar
    include PatternMatching

    attr_accessor :name

    def initialize(name = 'baz')
      @name = name
    end

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
    defn(:greet, _, _) { |_, name|
      "Hello, #{name}!"
    }

    defn(:hashable, _, {foo: :bar}, _) { |_, opts, _|
      :foo_bar
    }
    defn(:hashable, _, {foo: _}, _) { |_, opts, _|
      :foo_unbound
    }
    defn(:hashable, _, {}, _) { |_, opts, _|
      :unbound_unbound
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
  end

  let(:name) { 'Pattern Matcher' }
  subject { Foo.new(name) }

  specify { subject.greet.should eq 'Hello, World!' }

  specify { subject.greet('Jerry').should eq 'Hello, Jerry!' }

  specify { subject.greet(:male, 'Jerry').should eq 'Hello, Mr. Jerry!' }
  specify { subject.greet(:female, 'Jeri').should eq 'Hello, Ms. Jeri!' }
  specify { subject.greet(:unknown, 'Jerry').should eq 'Hello, Jerry!' }

  specify { subject.hashable(:male, {foo: :bar}, :female).should eq :foo_bar }
  specify { subject.hashable(:male, {foo: :baz}, :female).should eq :foo_unbound }
  specify { subject.hashable(:male, {foo: :bar, bar: :baz}, :female).should eq :foo_bar }
  specify { subject.hashable(:male, {bar: :baz}, :female).should eq :unbound_unbound }

  specify { subject.recurse.should eq 'w00t!' }
  specify { subject.recurse(:match).should eq 'w00t!' }
  specify { subject.recurse(:super).should eq 'Hello, World!' }
  specify { subject.recurse(:instance).should eq name }
  specify { subject.recurse(:foo).should eq :foo }

  specify { subject.concat(1, 1).should eq 2 }
  specify { subject.concat(1, 'shoe').should eq '1 shoe' }
  specify { subject.concat('shoe', 'fly').should eq 'shoefly' }

end
