module Wisper
  class BlockRegistration < Registration
    def broadcast(event, *args)
      if should_broadcast?(event)
        listener.call(*args)
      end
    end
  end
end
