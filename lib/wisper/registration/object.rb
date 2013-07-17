module Wisper
  class ObjectRegistration < Registration
    attr_reader :with

    def initialize(listener, options)
      super(listener, options)
      @with  = options[:with]
      fail_on_async if options.has_key?(:async)
    end

    def broadcast(event, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call)
        if listener.respond_to? :public_send
          listener.public_send(method_to_call, *args)
        else
          listener.send(method_to_call, *args)
        end
      end
    end

    private

    def map_event_to_method(event)
      with || event
    end

    def fail_on_async
      raise 'The async feature has been moved to the wisper-async gem'
    end
  end
end
