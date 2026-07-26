# frozen_string_literal: true

module Wisper
  # A registration created by {Publisher#on}, wrapping a block listener.
  # Unlike {ObjectRegistration}, block listeners are always called
  # directly (synchronously, in-process) and are not subject to
  # broadcaster/prefix/scope mapping.
  #
  # @api private
  class BlockRegistration < Registration
    # Calls the block listener if it is subscribed to `event`.
    #
    # @param event [Symbol, String] the (cleaned) broadcast event
    # @param _publisher [Object] the publisher which broadcast the event
    #   (unused; blocks are never scoped)
    # @param args [Array] positional arguments to pass to the block
    # @param kwargs [Hash] keyword arguments to pass to the block
    #
    # @return [Object, nil] the block's return value, or nil if not
    #   subscribed to this event
    def broadcast(event, _publisher, *, **)
      return unless should_broadcast?(event)

      listener.call(*, **)
    end
  end
end
