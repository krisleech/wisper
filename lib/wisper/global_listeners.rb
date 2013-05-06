require 'singleton'

module Wisper
  class GlobalListeners
    include Singleton

    def initialize
      @listeners = Set.new
    end

    def add_listener(listener, options = {})
      with_mutex { @listeners << ObjectRegistration.new(listener, options) }
      self
    end

    def listeners
      with_mutex { @listeners }
    end

    def clear
      with_mutex { @listeners.clear }
    end

    def self.add_listener(listener, options = {})
      instance.add_listener(listener, options)
    end

    def self.listeners
      instance.listeners
    end

    def self.clear
      instance.clear
    end

    private

    def mutex
      @mutex ||= Mutex.new
    end

    def with_mutex
      mutex.synchronize { yield }
    end
  end
end
