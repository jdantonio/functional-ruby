require 'functional/behavior'
require 'functional/behaviour'
require 'functional/either'
require 'functional/pattern_matching'
require 'functional/version'

Infinity = 1/0.0 unless defined?(Infinity)
NaN = 0/0.0 unless defined?(NaN)

module Functional

  class Configuration
    attr_accessor :behavior_check_on_construction

    def initialize
      @behavior_check_on_construction = false
    end

    def behavior_check_on_construction?
      !! @behavior_check_on_construction
    end
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
