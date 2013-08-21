require 'functional/behavior'
require 'functional/behaviour'
require 'functional/catalog'
require 'functional/collection'
require 'functional/inflect'
require 'functional/pattern_matching'
require 'functional/platform'
require 'functional/search'
require 'functional/sort'
require 'functional/utilities'
require 'functional/version'

Infinity = 1/0.0 unless defined?(Infinity)
NaN = 0/0.0 unless defined?(NaN)

module Functional

  class << self
    include Collection
    include Inflect
    include Search
    include Sort
  end
end
