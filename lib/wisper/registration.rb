module Wisper
  class Registration
    attr_reader :listener, :options

    def initialize(listener, options)
      @listener = listener
      @options = options
      fail_on_async if options.has_key?(:async) && !defined?(Broadcasters::Async)
    end

    def broadcast(event, publisher, *args)
      if broadcaster.should_broadcast?(event, publisher)
        broadcaster.broadcast_event(event, publisher, args)
      end
    end

    def method_name(event)
      prefix + (options[:with] || event).to_s
    end

    private

    def broadcaster
      @broadcaster ||= (
        options[:broadcaster] || Wisper.config.broadcaster || Broadcasters::DirectInvocation
      ).new(self, options)
    end

    def prefix
      _prefix = options[:prefix] || Wisper.config.prefix
      @prefix ||= case _prefix
      when nil
        ''
      when true
        default_prefix + '_'
      else
        _prefix.to_s + '_'
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
