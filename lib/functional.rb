require 'functional/either'
require 'functional/pattern_matching'
require 'functional/protocol'
require 'functional/type_check'
require 'functional/union'
require 'functional/version'

Infinity = 1/0.0 unless defined?(Infinity)
NaN = 0/0.0 unless defined?(NaN)

module Functional

  class Configuration
  end

  # create the default configuration on load
  @configuration = Configuration.new

  # @return [Configuration]
  def self.configuration
    @configuration
  end

  # Perform gem-level configuration.
  #
  # @yield the configuration commands
  # @yieldparam [Configuration] the current configuration object
  def self.configure
    yield(configuration)
  end
end
