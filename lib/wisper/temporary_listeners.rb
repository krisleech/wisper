# Handles temporary global subscriptions

# @api private

module Wisper
  class TemporaryListeners

    def self.subscribe(*listeners, &block)
      new.subscribe(*listeners, &block)
    end

    def self.registrations
      new.registrations
    end

    def subscribe(*listeners, &block)
      options = listeners.last.is_a?(Hash) ? listeners.pop : {}
      new_registrations = listeners.map { |listener| ObjectRegistration.new(listener, options) }
      begin
        registrations.merge new_registrations
        yield
      ensure
        registrations.subtract new_registrations
      end
      self
    end

    def registrations
      Thread.current[key] ||= Set.new
    end

    private

    def key
      '__wisper_temporary_listeners'
    end
  end
end
