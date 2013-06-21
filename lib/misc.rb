Infinity = 1/0.0 unless defined?(Infinity)
NaN = 0/0.0 unless defined?(NaN)

module Kernel

  def repl?
    return ($0 == 'irb' || $0 == 'pry' || !!($0 =~ /bundle$/))
  end

  def safe(*args, &block)
    result = nil
    t = Thread.new do
      $SAFE = 3
      result = self.instance_exec(*args, &block)
    end
    t.join
    return result
  end
end
