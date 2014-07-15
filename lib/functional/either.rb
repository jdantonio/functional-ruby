module Functional

  class Either

    attr_reader :left, :right

    # class methods

    def self.left(v)
      new(v, nil, true)
    end

    def self.right(v)
      new(nil, v, false)
    end

    class << self
      alias_method :reason, :left
      alias_method :value, :right
    end

    private_class_method :new

    # instance methods

    def left?
      @is_left
    end
    alias_method :reason?, :left?

    def right?
      ! left?
    end
    alias_method :value?, :right?

    alias_method :reason, :left
    alias_method :value, :right

    def swap
      self.class.send(:new, @right, @left, ! @is_left)
    end

    private

    def initialize(left, right, projection)
      @is_left = projection
      @left = left
      @right = right
    end
  end
end
