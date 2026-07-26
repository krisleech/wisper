# frozen_string_literal: true

module Wisper
  # Base class for a single listener's subscription: pairs a listener
  # with the set of events it should be notified of. Subclasses
  # ({ObjectRegistration}, {BlockRegistration}) implement `#broadcast`
  # for their respective listener types (objects and blocks).
  #
  # @api private
  class Registration
    # @return [ValueObjects::Events] the events this registration should
    #   broadcast to its listener
    attr_reader :on

    # @return [Object, Proc] the subscribed listener (an object or a block)
    attr_reader :listener

    # @param listener [Object, Proc] the listener being registered
    # @param options [Hash]
    # @option options [nil, String, Symbol, Array, Regexp] :on restricts
    #   which events this registration should broadcast; see
    #   {ValueObjects::Events}
    def initialize(listener, **options)
      @listener = listener
      @on = ValueObjects::Events.new options[:on]
    end

    private

    def should_broadcast?(event)
      on.include? event
    end
  end
end
