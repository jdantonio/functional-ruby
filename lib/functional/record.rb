require_relative 'abstract_struct'

module Functional

  # @see http://clojure.org/datatypes
  # @see http://clojure.github.io/clojure/clojure.core-api.html#clojure.core/defrecord
  # @see http://www.erlang.org/doc/reference_manual/records.html
  # @see http://www.erlang.org/doc/programming_examples/records.html
  module Record
    extend self

    # Create a new record class with the given members.
    #
    # @return [Functional::AbstractStruct] the new record subclass
    # @raise [ArgumentError] no members specified
    def new(*members)
      raise ArgumentError.new('no members provided') if members.empty?
      members = members.collect{|member| member.to_sym }.freeze
      build(Class.new{ include AbstractStruct }, members)
    end

    private

    def build(record, members)
      AbstractStruct.set_datatype(record, :record)
      AbstractStruct.set_members(record, members)
      define_initializer(record)
      members.each do |member|
        define_reader(record, member)
      end
      record
    end

    def define_initializer(record)
      record.send(:define_method, :initialize) do |data = {}|
        data = members.reduce({}) do |memo, member|
          # may eventually support default arguments
          memo[member] = data.fetch(member, nil)
          memo
        end
        set_data_hash(data)
        set_values_array(data.values)
      end
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
