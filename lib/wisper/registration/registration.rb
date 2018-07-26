# @api private

module Wisper
  class Registration
    attr_reader :on, :listener, :options

    def initialize(listener, options)
      @listener = listener
      @options = options
      @on = ValueObjects::Events.new options[:on]
    end

    private

    def should_broadcast?(event)
      on.include? event
    end
  end
end
