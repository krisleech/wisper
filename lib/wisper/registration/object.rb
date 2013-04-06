module Wisper
  class ObjectRegistration
    attr_reader :on, :with, :listener

    def initialize(listener, options)
      @listener   = listener
      @method     = options[:method]
      @on         = Array(options.fetch(:on) { 'all' }).map(&:to_s)
      @with       = options[:with]
    end

    def broadcast(event, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call)
        listener.public_send(method_to_call, *args)
      end
    end

    private

    def should_broadcast?(event)
      on.include?(event) || on.include?('all')
    end

    def map_event_to_method(event)
      self.with || event
    end
  end
end
