module Wisper
  class Registration
    attr_reader :on, :listener

    def initialize(listener, options)
      @listener   = listener
      @on         = Array(options.fetch(:on) { 'all' }).map(&:to_s)
    end

    private

    def should_broadcast?(event)
      on.include?(event) || on.include?('all')
    end
  end
end
