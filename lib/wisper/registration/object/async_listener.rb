class AsyncListener
  include Celluloid if defined?(Celluloid)

  attr_reader :listener, :event_method

  def initialize(listener, event_method)
    @listener     = listener
    @event_method = event_method.to_sym
  end

  def method_missing(method, *args, &block)
    if listener.respond_to?(method)
      if method == event_method
        listener.public_send(method, *args, &block)
        terminate
      else
        listener.public_send(method, *args, &block)
      end
    else
      super(method, *args, &block)
    end
  end
end
