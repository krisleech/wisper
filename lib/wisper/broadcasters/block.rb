module Wisper
  module Broadcasters
    class Block < Base
      def broadcast_event(event, _, args)
        listener.call(*args)
      end
    end
  end
end
