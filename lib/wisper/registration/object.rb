module Wisper

  class ObjectRegistration < Registration
    attr_reader :with, :prefix, :allowed_classes

    def initialize(listener, options)
      super(listener, options)
      @with   = options[:with]
      @prefix = stringify_prefix(options[:prefix])
      @allowed_classes = Array(options[:scope]).map(&:to_s).to_set
      fail_on_async if options.has_key?(:async)
    end

    def broadcast(event, publisher, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call) && publisher_in_scope?(publisher)
        listener.public_send(method_to_call, *args)
      end
    end

    private

    def publisher_in_scope?(publisher)
      allowed_classes.empty? || publisher.class.ancestors.any? { |ancestor| allowed_classes.include?(ancestor.to_s) }
    end

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

    def default_prefix
      'on'
    end

    def fail_on_async
      raise 'The async feature has been moved to the wisper-async gem'
    end
  end
end
