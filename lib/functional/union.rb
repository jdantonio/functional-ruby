module Functional

  class AbstractUnion

    @@formats = [].freeze

    attr_reader :value
    attr_reader :format

    class << self
      attr_reader :formats
    end

    def each
      return enum_for(:each) unless block_given?
      formats.each do |format|
        yield(format, self.send(format))
      end
    end

    def formats
      self.class.formats
    end

    def inspect
      state = to_h.to_s.gsub(/^{/, '').gsub(/}$/, '')
      "#<union #{self.class} #{state}>"
    end

    def to_h
      formats.reduce({}) do |memo, format|
        memo[format] = send(format)
        memo
      end
    end

    protected

    class << self
      attr_writer :formats
    end
    self.formats = [].freeze

    private_class_method :new

    private

    def initialize(format, value)
      @format = format
      @value = value
    end
  end

  # @see http://en.wikipedia.org/wiki/Union_type
  # @see http://www.ruby-doc.org/core-2.1.2/Struct.html
  module Union
    extend self

    def new(*formats)
      raise ArgumentError.new('no formats provided') if formats.empty?
      formats = formats.collect{|format| format.to_sym }.freeze

      union = Class.new(AbstractUnion) do
        formats.each do |format|
          # predicates
          define_method("#{format}?".to_sym) do
            @format == format
          end
          # readers
          define_method(format) do
            send("#{format}?".to_sym) ? @value : nil
          end
        end
      end

      # possible formats
      union.formats = formats

      # factories
      formats.each do |format|
        union.class.send(:define_method, format) do |value|
          new(format, value).freeze
        end
      end

      union
    end
  end
end
