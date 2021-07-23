# Handles temporary global subscriptions

# @api private

module Wisper
  class TemporaryListeners
    def self.subscribe(*listeners, **options, &block)
      new.subscribe(*listeners, **options, &block)
    end

    def self.registrations
      new.registrations
    end

    def subscribe(*listeners, **options, &_block)
      new_registrations = build_registrations(*listeners, **options)

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

    def build_registrations(*listeners, **options)
      listeners.map { |listener| ObjectRegistration.new(listener, **options) }
    end

    def key
      '__wisper_temporary_listeners'
    end
  end
end
