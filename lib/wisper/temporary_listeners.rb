# frozen_string_literal: true

module Wisper
  # Holds listeners subscribed via `Wisper.subscribe(...) { ... }`, i.e.
  # listeners which receive events broadcast by *any* publisher, but only
  # on the current thread and only for the duration of the given block.
  #
  # Registrations are stored per-thread (in `Thread.current`), so
  # temporary listeners are safe to use concurrently across threads, and
  # are cleared even if the block raises.
  #
  # @api private
  class TemporaryListeners
    # @see #subscribe
    def self.subscribe(*listeners, **, &)
      new.subscribe(*listeners, **, &)
    end

    # @see #registrations
    def self.registrations
      new.registrations
    end

    # Subscribes listeners for the duration of the given block, removing
    # them again once the block returns (or raises).
    #
    # @param listeners [Array<Object>] listeners to subscribe
    # @param options [Hash] see {ObjectRegistration#initialize}
    # @yield the block within which the listeners are subscribed
    #
    # @return [self]
    def subscribe(*listeners, **, &)
      new_registrations = build_registrations(*listeners, **)

      begin
        registrations.merge new_registrations
        yield
      ensure
        registrations.subtract new_registrations
      end
      self
    end

    # @return [Set<ObjectRegistration>] the registrations for the
    #   current thread
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
