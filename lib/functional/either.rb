module Functional

  class Either

    attr_reader :left, :right

    # class methods

    def self.left(v)
      new(v, nil, :left)
    end

    def self.right(v)
      new(nil, v, :right)
    end

    class << self
      alias_method :reason, :left
      alias_method :value, :right
    end

    private_class_method :new

    # instance methods

    def left?
      @projection == :left
    end
    alias_method :reason?, :left?

    def right?
      @projection == :right
    end
    alias_method :value?, :right?

    alias_method :reason, :left
    alias_method :value, :right

    private

    def initialize(left, right, projection)
      @projection = projection
      @left = left
      @right = right
    end
  end
end
