# @api private

module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :prefix, :allowed_classes, :broadcaster

    def initialize(listener, options)
      super(listener, options)
      @with   = options[:with]
      @prefix = ValueObjects::Prefix.new options[:prefix]
      @allowed_classes = Array(options[:scope]).map(&:to_s).to_set
      @broadcaster = map_broadcaster
    end

    def broadcast(event, publisher, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call) && publisher_in_scope?(publisher)
        broadcaster.broadcast(listener, publisher, method_to_call, args)
      end
    end

    private

    def publisher_in_scope?(publisher)
      allowed_classes.empty? || publisher.class.ancestors.any? { |ancestor| allowed_classes.include?(ancestor.to_s) }
    end

    def map_event_to_method(event)
      prefix + (with || event).to_s
    end

    # @return [Object] broadcaster instance
    def map_broadcaster
      key = broadcaster_key
      value = options[key]
      return value if value.respond_to?(:broadcast)

      broadcaster_with_options(key, value)
    end

    # @return [Symbol] key to fetch broadcaster by
    #
    # @example (setup => key)
    #   publisher.subscribe(Subscriber, async: Wisper::SidekiqBroadcaster.new)       # => :async
    #   publisher.subscribe(Subscriber, async: true)                                 # => :async
    #   publisher.subscribe(Subscriber, sidekiq: { queue: 'custom' })                # => :sidekiq
    #   publisher.subscribe(Subscriber)                                              # => :default
    #   publisher.subscribe(Subscriber, broadcaster: Wisper::SidekiqBroadcaster.new) # => :broadcaster
    #   publisher.subscribe(Subscriber, broadcaster: :custom)                        # => :custom
    #
    def broadcaster_key
      return :async if options.has_key?(:async) && options[:async]
      return :default unless options.has_key?(:broadcaster)
      options[:broadcaster].is_a?(Symbol) ? options[:broadcaster] : :broadcaster
    end

    # @param [Symbol] key - param to fetch broadcaster by
    # @param [Boolean, Nil, Hash, Object] value - broadcaster value. Allowed values are the following:
    #   nil                 # => default broadcaster
    #   false               # => default broadcaster
    #   true                # => async broadcaster
    #   Broadcaster.new     # => returns the provided broadcaster instance
    #   { queue: 'custom' } # => is used when broadcaster is configured as a callable object. In this case
    #                       #    the given options are passed to broadcaster initializer
    #
    # @return [Object] broadcaster instance for the given key / value pair
    #
    def broadcaster_with_options(key, value)
      result = configuration.broadcasters.fetch(key)
      result.respond_to?(:call) ? result.call(value) : result
    end

    def configuration
      Wisper.configuration
    end
  end
end
