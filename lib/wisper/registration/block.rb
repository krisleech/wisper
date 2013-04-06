module Wisper
  class BlockRegistration
    attr_reader :on, :listener

    def initialize(block, options)
      @listener   = block
      @on         = Array(options.fetch(:on) { 'all' }).map(&:to_s)
    end

    def broadcast(event, *args)
      if on.include?(event) || on.include?('all')
        listener.call(*args)
      end
    end
  end
end
