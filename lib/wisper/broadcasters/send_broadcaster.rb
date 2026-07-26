# frozen_string_literal: true

module Wisper
  module Broadcasters
    # The default broadcaster. Synchronously calls the mapped event method
    # directly on the listener, in-process, on the publishing thread.
    class SendBroadcaster
      # @param listener [Object] the listener to notify
      # @param _publisher [Object] the publisher which broadcast the event
      #   (unused by this broadcaster)
      # @param event [Symbol, String] the (already mapped) method to call
      #   on the listener
      # @param args [Array] positional arguments to pass to the listener
      # @param kwargs [Hash] keyword arguments to pass to the listener
      #
      # @return [Object] the return value of the listener method
      def broadcast(listener, _publisher, event, *, **)
        listener.public_send(event, *, **)
      end
    end
  end
end
