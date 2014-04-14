module Wisper
  class TemporaryListeners

    def self.with(*listeners, &block)
      options = listeners.last.is_a?(Hash) ? listeners.pop : {}
      new.with(listeners, options, &block)
    end

    def self.registrations
      new.registrations
    end

    def with(listeners, options, &block)
      begin
        add_listeners(listeners, options)
        yield
      ensure
        clear
      end
    end

    def registrations
      Thread.current[key] ||= Set.new
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
