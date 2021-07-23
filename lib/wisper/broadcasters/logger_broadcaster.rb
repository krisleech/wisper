# Provides a way of wrapping another broadcaster with logging

module Wisper
  module Broadcasters
    class LoggerBroadcaster
      def initialize(logger, broadcaster)
        @logger      = logger
        @broadcaster = broadcaster
      end

      def broadcast(listener, publisher, event, *args, **kwargs)
        @logger.info("[WISPER] #{name(publisher)} published #{event} to #{name(listener)} with #{args_info(args)} and #{kwargs_info(kwargs)}")
        @broadcaster.broadcast(listener, publisher, event, *args, **kwargs)
      end

      private

      def name(object)
        id_method  = %w(id uuid key object_id).find do |method_name|
          object.respond_to?(method_name) && object.method(method_name).arity <= 0
        end
        id         = object.send(id_method)
        class_name = object.class == Class ? object.name : object.class.name
        "#{class_name}##{id}"
      end

      def args_info(args)
        return 'no arguments' if args.empty?
        args.map do |arg|
          arg_string = name(arg)
          arg_string += ": #{arg.inspect}" if [Numeric, Array, Hash, String].any? {|klass| arg.is_a?(klass) }
          arg_string
        end.join(', ')
      end

      def kwargs_info(kwargs)
        kwargs.empty? ? 'no keyword arguments' : "keyword arguments #{kwargs.inspect}"
      end
    end
  end
end
