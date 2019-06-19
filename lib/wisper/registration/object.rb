# @api private

module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :prefix, :allowed_classes, :broadcaster

    def initialize(listener, options)
      super(listener, options)
      @with   = options[:with]
      @prefix = ValueObjects::Prefix.new options[:prefix]
      @allowed_classes = Array(options[:scope]).to_set
      @broadcaster = map_broadcaster(options[:async] || options[:broadcaster])
    end

    def broadcast(event, publisher, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call) && publisher_in_scope?(publisher)
        broadcaster.broadcast(listener, publisher, method_to_call, args)
      end
    end

    private

    def publisher_in_scope?(publisher)
      constantized_classes.empty? || publisher.class.ancestors.any? { |ancestor| constantized_classes.include?(ancestor) }
    end

    def constantized_classes
      @constantized_classes = allowed_classes.map do |klass|
        if klass.is_a?(String)
          class_from_string(klass)
        else
          klass
        end
      end
    end

    # support constant names, and also object IDs (<Class:objectid>
    def class_from_string(string)
      Object.const_get(string)
    end

    def map_event_to_method(event)
      prefix + (with || event).to_s
    end

    def map_broadcaster(value)
      return value if value.respond_to?(:broadcast)
      value = :async   if value == true
      value = :default if value == nil
      configuration.broadcasters.fetch(value)
    end

    def configuration
      Wisper.configuration
    end
  end
end
