require 'forwardable'

module Wisper
  class Configuration
    attr_reader :broadcasters

    def initialize
      @broadcasters = Broadcasters.new
    end

    def broadcaster(name, broadcaster)
      @broadcasters[name] = broadcaster
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
