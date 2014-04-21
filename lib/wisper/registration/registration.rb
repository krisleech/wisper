module Wisper
  class Registration
    attr_reader :on, :listener

    def initialize(listener, options)
      @listener   = listener
      @on         = Array(options.fetch(:on) { 'all' }).map(&:to_s)
    end
    
    def listener
      case @listener
        when Class
          clazz = Kernel.const_get(@listener.to_s)
          clazz.new
        when String
          clazz = Kernel.const_get(@listener)
          clazz.new
        else
          @listener
      end
    end

    private

    def should_broadcast?(event)
      on.include?(event) || on.include?('all')
    end
  end
end
