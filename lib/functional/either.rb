module Functional

  class Either

    attr_reader :left, :right

    # class methods

    def self.left(v)
      new(v, nil, true).freeze
    end

    def self.right(v)
      new(nil, v, false).freeze
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

    def either(lproc, rproc)
      if left?
        lproc.call(left)
      else
        rproc.call(right)
      end
    end

    def self.iff(*args)
      raise ArgumentError.new("wrong number of arguments (#{args.length} for 2..3)") if args.length < 2 || args.length > 3
      raise ArgumentError.new('requires either a boolean expression or a block, not both') if args.length == 3 && block_given?
      boolean = block_given? ? yield : !! args.last
      boolean ? left(args[0]) : right(args[1])
    end

    def reduce
      left? ? left : right
    end

    private

    def initialize(left, right, projection)
      @is_left = projection
      @left = left
      @right = right
    end
  end
end
