require 'functional/either'
require 'functional/pattern_matching'
require 'functional/protocol'
require 'functional/protocol_info'
require 'functional/record'
require 'functional/type_check'
require 'functional/union'
require 'functional/version'

# Erlang, Clojure, and Go inspired functional programming tools to Ruby.
module Functional

  # Infinity
  Infinity = 1/0.0

  # Not a number
  NaN = 0/0.0

  # A gem-level configuration class.
  class Configuration
  end

  # create the default configuration on load
  @configuration = Configuration.new

  # The current gem configutation.
  #
  # @return [Functional::Configuration]
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
