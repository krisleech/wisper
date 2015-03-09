# Handles global subscriptions

# @api private

require 'singleton'

module Wisper
  class GlobalListeners
    include Singleton

    def initialize
      @registrations = Set.new
      @mutex         = Mutex.new
    end

    def subscribe(*listeners, &block)
      options = listeners.last.is_a?(Hash) ? listeners.pop : {}

      with_mutex do
        listeners.each do |listener|
          @registrations << ObjectRegistration.new(listener, options, &block)
        end
      end
      self
    end

    def registrations
      with_mutex { @registrations }
    end

    def listeners
      registrations.map(&:listener).freeze
    end

    def clear
      with_mutex { @registrations.clear }
    end

    def self.subscribe(*listeners)
      instance.subscribe(*listeners)
    end

    def self.registrations
      instance.registrations
    end

    def self.listeners
      instance.listeners
    end

    def self.clear
      instance.clear
    end

    private

    def with_mutex
      @mutex.synchronize { yield }
    end
  end
end
