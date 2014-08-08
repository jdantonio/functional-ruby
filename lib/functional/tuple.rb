module Functional

  # @note The current implementation uses simple Ruby arrays. This is likely to be
  # very inefficient for all but the smallest tuples. The more elements the tuple
  # contains, the less efficient it will become. A future version will use a fast,
  # immutable, persistent data structure such as a finger tree or a trie.
  # 
  # @see http://en.wikipedia.org/wiki/Tuple
  # @see http://msdn.microsoft.com/en-us/library/system.tuple.aspx
  # @see http://www.tutorialspoint.com/python/python_tuples.htm
  # @see http://en.cppreference.com/w/cpp/utility/tuple
  # @see http://docs.oracle.com/javaee/6/api/javax/persistence/Tuple.html
  # @see http://www.erlang.org/doc/reference_manual/data_types.html
  # @see http://www.erlang.org/doc/man/erlang.html#make_tuple-2
  # @see http://en.wikibooks.org/wiki/Haskell/Lists_and_tuples#Tuples
  class Tuple

    # initialize
    # [] at
    # fetch
    # length, size
    # & intersection
    # | union
    # + concatenation
    # - difference
    # * repetition (concat x number of times)
    # uniq
    # each
    # each_with_index
    # sequence - iterate with head and tail
    # eql?
    # empty?
    # to_a
    # first (head)
    # rest (tail)
  end
end
