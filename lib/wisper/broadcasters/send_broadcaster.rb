module Wisper
  module Broadcasters
    class SendBroadcaster
      def broadcast(listener, publisher, event, *args, **kwargs)
        listener.public_send(event, *args, **kwargs)
      end
    end
  end
end
