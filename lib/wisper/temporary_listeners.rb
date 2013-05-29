module Wisper
  class TemporaryListeners
    include Singleton

    def with(listener_or_listeners, options = {}, &block)
      add_listeners(Array(listener_or_listeners), options)
      yield
      clear
    end

    def registrations
      Thread.current[key] ||= Set.new
    end

    def self.with(listener_or_listeners, options = {}, &block)
      instance.with(listener_or_listeners, options, &block)
    end

    def self.registrations
      instance.registrations
    end

    private

    def clear
      registrations.clear
    end

    def add_listeners(listeners, options)
      listeners.each { |listener| add_listener(listener, options)}
    end

    def add_listener(listener, options)
      registrations << ObjectRegistration.new(listener, options)
    end


    def key
      '__wisper_temporary_listeners'
    end
  end
end
