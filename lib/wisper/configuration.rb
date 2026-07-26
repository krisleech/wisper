# frozen_string_literal: true

require 'forwardable'

module Wisper
  # Holds process-wide Wisper configuration: the registry of named
  # {Broadcasters} and the default event prefix.
  #
  # A single instance is memoized at {Wisper.configuration} and is
  # typically modified via {Wisper.configure}.
  class Configuration
    # @return [Broadcasters] the registry of named broadcasters
    attr_reader :broadcasters

    def initialize
      @broadcasters = Broadcasters.new
    end

    # Registers a broadcaster, referenced by key.
    #
    # @param key [String, Symbol, #to_s] an arbitrary key, referenced by
    #   `broadcaster:`/`async:` when subscribing a listener
    # @param broadcaster [#broadcast] a broadcaster
    #
    # @return [self]
    def broadcaster(key, broadcaster)
      @broadcasters[key] = broadcaster
      self
    end

    # Sets the default value substituted when a listener is subscribed
    # with `prefix: true`.
    #
    # @param value [#to_s]
    #
    # @return [String]
    def default_prefix=(value)
      ValueObjects::Prefix.default = value
    end

    # A simple key/broadcaster registry, keyed by whatever was passed to
    # {Configuration#broadcaster} (typically a Symbol).
    class Broadcasters
      extend Forwardable

      def_delegators :@data, :[], :[]=, :empty?, :include?, :clear, :keys, :to_h

      def initialize
        @data = {}
      end

      # @param key [Object] a previously registered broadcaster key
      # @raise [KeyError] if no broadcaster is registered under `key`
      # @return [#broadcast] the registered broadcaster
      def fetch(key)
        raise KeyError, "broadcaster not found for #{key}" unless include?(key)

        @data[key]
      end
    end
  end
end
