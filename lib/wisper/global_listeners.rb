require 'singleton'

module Wisper
  class GlobalListeners
    include Singleton
    attr_reader :mutex
    private :mutex

    def initialize
      @registrations = Set.new
      @mutex         = Mutex.new
    end

    def add_listener(listener, options = {})
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

    def self.add_listener(listener, options = {})
      instance.add_listener(listener, options)
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
      mutex.synchronize { yield }
    end
  end
end
