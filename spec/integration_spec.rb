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
  end

  subject { Foo.new }

  specify { subject.greet.should eq 'Hello, World!' }

  specify { subject.greet('Jerry').should eq 'Hello, Jerry!' }

  specify { subject.greet(:male, 'Jerry').should eq 'Hello, Mr. Jerry!' }
  specify { subject.greet(:female, 'Jeri').should eq 'Hello, Ms. Jeri!' }
  specify { subject.greet(:unknown, 'Jerry').should eq 'Hello, Jerry!' }

end
