module Wisper
  module Publisher
    def listeners
      registrations.map(&:listener).freeze
    end

    def subscribe(listener, options = {})
      local_registrations << ObjectRegistration.new(listener, options)
      self
    end

    def on(*events, &block)
      raise ArgumentError, 'must give at least one event' if events.empty?
      local_registrations << BlockRegistration.new(block, on: events)
      self
    end

    module ClassMethods
      def subscribe(listener, options = {})
        GlobalListeners.subscribe(listener, options.merge(:scope => self))
      end
    end

    private

    def local_registrations
      @local_registrations ||= Set.new
    end

    def global_registrations
      GlobalListeners.registrations
    end

    def temporary_registrations
      TemporaryListeners.registrations
    end

    def registrations
      local_registrations + global_registrations + temporary_registrations
    end

    def broadcast(event, *args)
      registrations.each do | registration |
        registration.broadcast(clean_event(event), self, *args)
      end
    end

    alias :publish  :broadcast
    alias :announce :broadcast

    def clean_event(event)
      event.to_s.gsub('-', '_')
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

