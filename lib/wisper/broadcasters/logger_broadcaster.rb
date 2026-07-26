# frozen_string_literal: true

module Wisper
  module Broadcasters
    # Wraps another broadcaster, logging every broadcast before delegating
    # to it.
    #
    # @example
    #   publisher.subscribe(listener,
    #     broadcaster: LoggerBroadcaster.new(Rails.logger, SendBroadcaster.new))
    class LoggerBroadcaster
      # @param logger [#info] any object responding to `#info(String)`,
      #   e.g. a `Logger` instance
      # @param broadcaster [#broadcast] the broadcaster to delegate to
      #   after logging
      def initialize(logger, broadcaster)
        @logger      = logger
        @broadcaster = broadcaster
      end

      # Logs the broadcast and then delegates it to the wrapped
      # broadcaster.
      #
      # @param listener [Object] the subscribed listener
      # @param publisher [Object] the publisher which broadcast the event
      # @param event [Symbol, String] the (already mapped) method to call
      #   on the listener
      # @param args [Array] positional arguments to pass to the listener
      # @param kwargs [Hash] keyword arguments to pass to the listener
      #
      # @return [void]
      def broadcast(listener, publisher, event, *args, **kwargs)
        @logger.info(log_message(listener, publisher, event, args, kwargs))
        @broadcaster.broadcast(listener, publisher, event, *args, **kwargs)
      end

      private

      def log_message(listener, publisher, event, args, kwargs)
        "[WISPER] #{name(publisher)} published #{event} to #{name(listener)} " \
          "with #{args_info(args)} and #{kwargs_info(kwargs)}"
      end

      def name(object)
        id_method = %w[id uuid key object_id].find do |method_name|
          object.respond_to?(method_name) && object.method(method_name).arity <= 0
        end
        id         = object.send(id_method)
        class_name = object.instance_of?(Class) ? object.name : object.class.name
        "#{class_name}##{id}"
      end

      def args_info(args)
        return 'no arguments' if args.empty?

        args.map do |arg|
          arg_string = name(arg)
          arg_string += ": #{arg.inspect}" if [Numeric, Array, Hash, String].any? { |klass| arg.is_a?(klass) }
          arg_string
        end.join(', ')
      end

      def kwargs_info(kwargs)
        kwargs.empty? ? 'no keyword arguments' : "keyword arguments #{kwargs.inspect}"
      end
    end
  end
end
