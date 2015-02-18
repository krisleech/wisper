require 'forwardable'

module Wisper
  class Configuration
    attr_reader :broadcasters

    def initialize
      @broadcasters = Broadcasters.new
    end

    # registers a broadcaster, referenced by key
    #
    # @param key [String, #to_s] an arbitrary key
    # @param broadcaster [#broadcast] a broadcaster
    def broadcaster(key, broadcaster)
      @broadcasters[key] = broadcaster
      self
    end

    class Broadcasters
      extend Forwardable

      def_delegators :@data, :[], :[]=, :empty?, :include?, :clear

      def initialize
        @data = {}
      end

      def fetch(key)
        raise KeyError, "broadcaster not found for #{key}" unless include?(key)
        @data[key]
      end
    end
  end
end
