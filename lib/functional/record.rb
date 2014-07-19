require_relative 'abstract_struct'

module Functional

  # @see http://clojure.org/datatypes
  # @see http://clojure.github.io/clojure/clojure.core-api.html#clojure.core/defrecord
  # @see http://www.erlang.org/doc/reference_manual/records.html
  # @see http://www.erlang.org/doc/programming_examples/records.html
  module Record
    extend self

    def new(*members)
      raise ArgumentError.new('no members provided') if members.empty?
      members = members.collect{|member| member.to_sym }.freeze
      build(Class.new(AbstractStruct), members)
    end

    private

    def build(record, members)
      record.send(:set_datatype, :record)
      set_members(record, members)
      members.each do |member|
        define_reader(record, member)
      end
      record
    end

    def set_members(record, members)
      record.send(:members=, members)
      record
    end

    def define_reader(record, member)
      record.send(:define_method, member) do
        to_h[member]
      end
      record
    end
  end
end
