require 'rspec/expectations'

module Wisper
  module RSpec
    class EventRecorder
      def initialize
        @broadcast_events = []
      end

      def respond_to?(method_name)
        true
      end

      def method_missing(method_name, *args, &block)
        @broadcast_events << method_name.to_s
      end

      def broadcast?(event_name)
        @broadcast_events.include?(event_name.to_s)
      end
    end

    module BroadcastMatcher
      class Matcher
        def initialize(event)
          @event = event
        end

        def supports_block_expectations?
          true
        end

        def matches?(block)
          event_recorder = EventRecorder.new

          Wisper.subscribe(event_recorder) do
            block.call
          end

          event_recorder.broadcast?(@event)
        end

        def failure_message
          "expected publisher to broadcast #{@event} event"
        end

        def failure_message_when_negated
          "expected publisher not to broadcast #{@event} event"
        end
      end

      def broadcast(event)
        Matcher.new(event)
      end
    end
  end
end
