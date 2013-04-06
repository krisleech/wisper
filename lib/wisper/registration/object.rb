module Wisper
  class ObjectRegistration < Registration
    attr_reader :with

    def initialize(listener, options)
      super(listener, options)
      @with = options[:with]
    end

    def broadcast(event, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call)
        listener.public_send(method_to_call, *args)
      end
    end

    private

    def map_event_to_method(event)
      with || event
    end
  end
end
