# Provides a way of wrapping another broadcaster with logging

module Wisper
  module Broadcasters
    class LoggerBroadcaster
      def initialize(logger, broadcaster)
        @logger      = logger
        @broadcaster = broadcaster
      end

      def broadcast(listener, publisher, event, args)
        @logger.info("[WISPER] #{name(publisher)} published #{event} to #{name(listener)} with #{arg_names(args)}")
        @broadcaster.broadcast(listener, publisher, event, args)
      end

      private

      def name(object)
        id_method  = %w(id uuid key object_id).find { |method_name| object.respond_to?(method_name) }
        id         = object.send(id_method)
        class_name = object.class == Class ? object.name : object.class.name
        "#{class_name}##{id}"
      end

      def arg_names(args)
        return 'no arguments' if args.empty?
        args.map { |arg| name(arg) }.join(', ')
      end
    end
  end
end
