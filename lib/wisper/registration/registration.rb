module Wisper
  class Registration
    attr_reader :on, :listener

    def initialize(listener, on: nil)
      @listener   = listener
      on ||= 'all'
      @on = Array(on).map(&:to_s)
    end

    private

    def should_broadcast?(event)
      on.include?(event) || on.include?('all')
    end
  end
end
