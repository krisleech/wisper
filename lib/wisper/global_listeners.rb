require 'singleton'

module Wisper
  class GlobalListeners
    include Singleton

    def initialize
      @registrations = Set.new
      @mutex         = Mutex.new
    end

    def add(listener, options = {})
      with_mutex { @registrations << ObjectRegistration.new(listener, options) }
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

    def self.add(listener, options = {})
      instance.add(listener, options)
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

    # remain backwards compatible
    def self.add_listener(listener, options = {})
      warn "[DEPRECATION] use `add` instead of `add_listener`"
      add(listener, options)
    end

    private

    def with_mutex
      @mutex.synchronize { yield }
    end
  end
end
