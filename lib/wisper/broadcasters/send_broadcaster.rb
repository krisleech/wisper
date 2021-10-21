module Wisper
  module Broadcasters
    class SendBroadcaster
      ruby2_keywords def broadcast(listener, publisher, event, *args)
        listener.public_send(event, *args)
      end
    end
  end
end
