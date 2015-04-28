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
    end
  end

  module Publisher
    alias_method :broadcast_real, :broadcast

    def broadcast(event, *args)
      Publisher.record_testing_event(event, *args)
      if Wisper::Testing.fake?
        true
      else
        broadcast_real(event, *args)
      end
    end

    class << self
      def record_testing_event(event, *args)
        @testing_event_recorder.send(event, *args) if @testing_event_recorder
      end

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
end