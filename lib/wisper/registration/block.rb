# @api private

module Wisper
  class BlockRegistration < Registration
    ruby2_keywords def broadcast(event, publisher, *args)
      if should_broadcast?(event)
        listener.call(*args)
      end
    end
  end
end
