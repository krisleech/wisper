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

      def disable!(&block)
        __set_test_mode(:disable, &block)
      end

      def fake!(&block)
        __set_test_mode(:fake, &block)
      end

      def enabled?
        self.__test_mode != :disable
      end

      def disabled?
        self.__test_mode == :disable
      end

      def fake?
        self.__test_mode == :fake
      end

      attr_accessor :__patch_state

      # Performs any patching necessary for Wisper::Testing to function.
      def patch!
        return if patched?
        Wisper::Publisher.wisper_testing_patch!
        self.__patch_state = :patched
      end

      # Restores Wisper and related objects to their original state before {#patch} was called.
      def unpatch!
        return unless patched?
        Wisper::Publisher.wisper_testing_unpatch!
        self.__patch_state = :unpatched
      end

      def patched?
        self.__patch_state == :patched
      end
    end
  end

  module Publisher
    # If testing is in "fake" mode, returns `true` as if broadcasting worked. If not in "fake"
    # mode, broadcasts the event using the original `broadcast` method.
    # This allows tests to determine whether an event was broadcast, and optionally skip the
    # delivery of the event.
    def broadcast_testing(event, *args)
      Publisher.record_testing_event(event, *args)
      if Wisper::Testing.fake?
        true
      else
        broadcast_real(event, *args)
      end
    end

    def self.wisper_testing_patch!
      alias_method :broadcast_real, :broadcast
      alias_method :broadcast, :broadcast_testing
      alias_method :publish, :broadcast_testing
      private :broadcast, :publish
    end

    def self.wisper_testing_unpatch!
      alias_method :broadcast, :broadcast_real
      alias_method :publish, :broadcast_real
      private :broadcast, :publish
    end

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
    def subscribed_to_publisher?(listener, publisher_class)
      registrations.any? { |reg|
        reg.listener == listener && reg.allowed_classes.include?(publisher_class.to_s)
      }
    end
  end
end

unless ENV['SKIP_WISPER_TESTING_PATCH']
  Wisper::Testing.patch!
end
