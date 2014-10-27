module Wisper
  module Publisher
    def listeners
      registrations.map(&:listener).freeze
    end

    def subscribe(listener, on: nil, with: nil, prefix: nil, scope: nil, broadcaster: nil, async: nil)
      local_registrations << ObjectRegistration.new(listener, on: on,
                                                              with: with,
                                                              prefix: prefix,
                                                              scope: scope,
                                                              broadcaster: broadcaster,
                                                              async: async)
      self
    end

    def on(*events, &block)
      raise ArgumentError, 'must give at least one event' if events.empty?
      local_registrations << BlockRegistration.new(block, on: events)
      self
    end

    module ClassMethods
      def subscribe(listener, on: nil, with: nil, prefix: nil, broadcaster: nil, async: nil)
        GlobalListeners.subscribe(listener, on: on,
                                            with: with,
                                            prefix: prefix,
                                            scope: self,
                                            broadcaster: broadcaster,
                                            async: async)
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
