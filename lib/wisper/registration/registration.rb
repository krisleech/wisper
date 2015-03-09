# @api private

module Wisper
  class Registration
    attr_reader :on, :listener, :error_handler

    ALL = Object.new.freeze

    def initialize(listener, options, &block)
      @listener      = listener
      @on            = stringify(options.fetch(:on, ALL))
      @error_handler = block
    end

    private

    def should_broadcast?(event)
      return true if on == ALL

      case on.class.name
      when 'String'
        event == on
      when 'Array'
        on.include?(event)
      when 'Regexp'
        !!on.match(event)
      else
        raise ArgumentError, "#{on.class} not supported for `on` argument"
      end
    end

    def stringify(on)
      case on.class.name
      when 'Symbol'
        on.to_s
      when 'Array'
        on.map(&:to_s)
      else
        on
      end
    end
  end
end
