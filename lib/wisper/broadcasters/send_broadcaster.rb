module Wisper
  module Broadcasters
    class SendBroadcaster
      def broadcast(listener, publisher, method_to_call, _event, *args, **kwargs)
        listener.public_send(method_to_call, *args, **kwargs)
      end
    end
  end
end
