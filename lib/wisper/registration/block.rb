# @api private

module Wisper
  class BlockRegistration < Registration
    def broadcast(event, publisher, *args, **kwargs)
      if should_broadcast?(event)
        listener.call(*args, **kwargs)
      end
    end
  end
end
