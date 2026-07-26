# frozen_string_literal: true

require 'singleton'

module Wisper
  # Holds listeners subscribed via `Wisper.subscribe` (with no block),
  # i.e. listeners which receive events broadcast by *any* publisher, on
  # *any* thread, until explicitly unsubscribed.
  #
  # A single, thread-safe instance is held via the Singleton pattern; the
  # class methods below delegate to it and are the intended public
  # interface (used internally by {Wisper.subscribe} et al).
  #
  # @api private
  class GlobalListeners
    include Singleton

    def initialize
      @registrations = Set.new
      @mutex         = Mutex.new
    end

    # @param listeners [Array<Object>] listeners to subscribe
    # @param options [Hash] see {ObjectRegistration#initialize}
    # @return [self]
    def subscribe(*listeners, **options)
      with_mutex do
        listeners.each do |listener|
          @registrations << ObjectRegistration.new(listener, **options)
        end
      end
      self
    end

    # @param listeners [Array<Object>] previously subscribed listeners to remove
    # @return [self]
    def unsubscribe(*listeners)
      with_mutex do
        @registrations.delete_if do |registration|
          listeners.include?(registration.listener)
        end
      end
      self
    end

    # @return [Set<ObjectRegistration>] a thread-safe snapshot of the
    #   current registrations
    def registrations
      with_mutex { @registrations }
    end

    # @return [Array<Object>] the currently subscribed listener objects,
    #   frozen
    def listeners
      registrations.map(&:listener).freeze
    end

    # Removes all global listeners.
    #
    # @return [void]
    def clear
      with_mutex { @registrations.clear }
    end

    # @see #subscribe
    def self.subscribe(*listeners, **)
      instance.subscribe(*listeners, **)
    end

    # @see #unsubscribe
    def self.unsubscribe(*listeners)
      instance.unsubscribe(*listeners)
    end

    # @see #registrations
    def self.registrations
      instance.registrations
    end

    # @see #listeners
    def self.listeners
      instance.listeners
    end

    # @see #clear
    def self.clear
      instance.clear
    end

    private

    def with_mutex(&)
      @mutex.synchronize(&)
    end
  end
end
