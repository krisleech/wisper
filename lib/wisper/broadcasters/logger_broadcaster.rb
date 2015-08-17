# Provides a way of wrapping another broadcaster with logging

module Wisper
  module Broadcasters
    class LoggerBroadcaster
      def initialize(logger, broadcaster)
        @logger      = logger
        @broadcaster = broadcaster
      end

      def broadcast(subscriber, publisher, event, args)
        @logger.info("[WISPER] #{name(publisher)} published #{event} to #{name(subscriber)} with #{arg_names(args)}")
        @broadcaster.broadcast(subscriber, publisher, event, args)
      end

      private

      def name(object)
        id_method  = %w(id uuid key object_id).find { |possibility| object.respond_to?(possibility) }
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
