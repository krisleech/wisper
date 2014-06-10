module Wisper
  module Broadcasters
    class SendBroadcaster
      def broadcast(subscriber, publisher, event, args)
        subscriber.public_send(event, *args)
      end
    end
  end
end
