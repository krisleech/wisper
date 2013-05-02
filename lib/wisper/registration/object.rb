begin
  require 'celluloid/autostart'
rescue LoadError
  # no-op
end

module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :async

    def initialize(listener, options)
      super(listener, options)
      @with  = options[:with]
      @async = options.fetch(:async, false)
    end

    def broadcast(event, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call)
        unless async
          listener.public_send(method_to_call, *args)
        else
          AsyncListener.new(listener, method_to_call).async.public_send(method_to_call, *args)
        end
      end
    end

    private

    def map_event_to_method(event)
      with || event
    end
  end
end
