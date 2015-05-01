require 'wisper'

module Wisper
  class Testing
    class << self
      attr_accessor :__test_mode

      def __set_test_mode(mode, &block)
        if block
          current_mode = self.__test_mode
          begin
            self.__test_mode = mode
            block.call
          ensure
            self.__test_mode = current_mode
          end
        else
          self.__test_mode = mode
        end
      end

      def enable!(&block)
        __set_test_mode(:enabled, &block)
      end

      def disable!(&block)
        __set_test_mode(:disable, &block)
      end

      def enabled?
        self.__test_mode != :disable
      end

      def disabled?
        self.__test_mode == :disable
      end
    end
  end

  module Publisher
    alias_method :broadcast_real, :broadcast

    # Broadcasts an event if Testing.enabled? but always returns `true` as if it worked.
    # This allows tests to determine whether an event was broadcast, and optionally skip the
    # delivery of the event.
    def broadcast(event, *args)
      Publisher.record_testing_event(event, *args)
      if Wisper::Testing.enabled?
        broadcast_real(event, *args)
      else
        true
      end
    end
    alias_method :publish, :broadcast

    private :broadcast, :publish

    # Allows tests to ask a Wisper publisher whether a listener has been subscribed to events
    # from it.
    def wisper_subscribed_locally?(listener)
      local_registrations.any? { |registration| registration.listener == listener }
    end

    class << self
      attr_reader :testing_event_recorder

      def record_testing_event(event, *args)
        testing_event_recorder.send(event, *args) if testing_event_recorder
      end

      # Allows tests to run a block that records all events sent during the block.
      # `event_recorder` will have the event sent to it as if it were a listener that
      # is subscribed to any of the events broadcast during this method's run.
      def with_testing_event_recorder(event_recorder)
        @testing_event_recorder = event_recorder
        begin
          yield
        ensure
          @testing_event_recorder = nil
        end
      end
    end
  end

  class << self
    # List of all registrations that exist in Wisper.
    def registrations
      GlobalListeners.registrations + TemporaryListeners.registrations
    end

    # Determines whether an object is registered as a listener within Wisper.
    def subscribed?(listener)
      registrations.any? { |reg| reg.listener == listener }
    end

    # Determines whether an object is registered as a listener for a specific publisher object.
    def subscribed_to_publisher?(listener, publisher)
      registrations.any? { |reg|
        reg.listener == listener && reg.allowed_classes.include?(publisher.to_s)
      }
    end
  end
end
