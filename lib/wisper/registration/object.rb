module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :prefix, :delay

    def initialize(listener, options)
      super(listener, options)
      @with   = options[:with]
			@delay  = options[:delay]
      @prefix = stringify_prefix(options[:prefix])
      fail_on_async if options.has_key?(:async)
    end

    def broadcast(event, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call)
				if delay
					listener.delay(delay_options).public_send(method_to_call, *args)
				else
					listener.public_send(method_to_call, *args)
				end
      end
    end

    private

    def map_event_to_method(event)
      prefix + (with || event).to_s
    end

    def stringify_prefix(_prefix)
      case _prefix
      when nil
        ''
      when true
        default_prefix + '_'
      else
        _prefix.to_s + '_'
      end
    end

		def delay_options
			if delay.is_a?(Hash)
				delay
			else
				{}
			end
		end

    def default_prefix
      'on'
    end

    def fail_on_async
      raise 'The async feature has been moved to the wisper-async gem'
    end
  end
end
