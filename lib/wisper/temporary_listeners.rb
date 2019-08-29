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

    def subscribe(*listeners, &_block)
      new_registrations = build_registrations(listeners)

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

    def build_registrations(listeners)
      options = listeners.last.is_a?(Hash) ? listeners.pop : {}
      listeners.map { |listener| ObjectRegistration.new(listener, options) }
    end

    def key
      '__wisper_temporary_listeners'
    end
  end
end
