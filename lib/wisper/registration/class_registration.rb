module Wisper
  class ClassRegistration < ObjectRegistration

    def broadcast(event, publisher, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.method_defined?(method_to_call) && publisher_in_scope?(publisher)
        listener.new.public_send(method_to_call, *args)
      end
    end
  end
end
