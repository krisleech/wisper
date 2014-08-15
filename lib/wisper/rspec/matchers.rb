require 'rspec/expectations'

module Wisper
  module Rspec
    class EventRecorder
      def initialize
        @broadcast_events = []
      end

      def respond_to?(method_name)
        true
      end

      def method_missing(method_name, *args, &block)
        @broadcast_events << Event.new(method_name.to_s, args)
      end

      def broadcast?(event_name, args = nil)
        if args.nil?
          !!@broadcast_events.find { |event| event.name == event_name.to_s }
        else
          @broadcast_events.include?(Event.new(event_name.to_s, args))
        end
      end

      # TODO: make === equality string/symbol agnostic for name
      class Event < Struct.new(:name, :args); end
    end

    module BroadcastMatcher
      class Matcher
        def initialize(event_name, options)
          @event = event_name
          @args  = options.key?(:with) ? Array(options[:with]) : nil
        end

        def supports_block_expectations?
          true
        end

        def matches?(block)
          event_recorder = EventRecorder.new

          Wisper.with_listeners(event_recorder) do
            block.call
          end

          event_recorder.broadcast?(@event, @args)
        end

        def failure_message
          message = "expected publisher to broadcast #{@event} event"
          message << " with arguments #{@args.join(', ')}" if with_args?
          message
        end

        def failure_message_when_negated
          message = "expected publisher not to broadcast #{@event} event"
          message << " with arguments #{@args.join(', ')}" if with_args?
          message
        end

        private

        def with_args?
          !@args.nil?
        end
      end

      def broadcast(event_name, options = {})
        Matcher.new(event_name, options)
      end
    end
  end
end
