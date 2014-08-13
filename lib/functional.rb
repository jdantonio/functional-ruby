require 'functional/delay'
require 'functional/either'
require 'functional/final_struct'
require 'functional/final_var'
require 'functional/memo'
require 'functional/option'
require 'functional/pattern_matching'
require 'functional/protocol'
require 'functional/protocol_info'
require 'functional/record'
require 'functional/tuple'
require 'functional/type_check'
require 'functional/union'
require 'functional/value_struct'
require 'functional/version'

Functional::SpecifyProtocol(:Disposition) do
  instance_method :value, 0
  instance_method :value?, 0
  instance_method :reason, 0
  instance_method :reason?, 0
  instance_method :fulfilled?, 0
  instance_method :rejected?, 0
end

require 'atomic'
require 'concurrent'
atomic1 = Atomic.new(42)
atomic2 = Concurrent::Atomic.new(42)

# Erlang, Clojure, and Go inspired functional programming tools to Ruby.
module Functional

  # Infinity
  Infinity = 1/0.0

  # Not a number
  NaN = 0/0.0

  # A gem-level configuration class.
  # @!visibility private
  class Configuration
  end

  # create the default configuration on load
  # @!visibility private
  @configuration = Configuration.new

  # The current gem configutation.
  #
  # @return [Functional::Configuration]
  #
  # @!visibility private
  def self.configuration
    @configuration
  end

  # Perform gem-level configuration.
  #
  # @yield the configuration commands
  # @yieldparam [Functional::Configuration] the current configuration object
  def self.configure
    yield(configuration)
  end
end
