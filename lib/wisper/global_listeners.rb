require 'singleton'

module Wisper
  class GlobalListeners
    include Singleton

    def initialize
      @listeners = Set.new
    end

    def add_listener(listener, options = {})
      listeners << ObjectRegistration.new(listener, options)
      self
    end

    def listeners
      @listeners
    end

    def self.add_listener(listener, options = {})
      instance.add_listener(listener, options)
    end

    def self.listeners
      instance.listeners
    end
  end
end
