# @api private

module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :prefix, :allowed_classes, :broadcaster

    def initialize(listener, options)
      super(listener, options)
      @with   = options[:with]
      @prefix = ValueObjects::Prefix.new options[:prefix]
      @allowed_classes = normalize_classes(Array(options[:scope]))
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
      anonymous_ancestors = nil

      allowed_classes.empty? || allowed_classes.any? do |klass|
        if klass.is_a?(String)
          # NOTE: This conditional branch contains expensive and time-consuming operations.
          #       Avoid this branch if possible.

          if anonymous_ancestors.nil?
            # A class without a name is an anonymous class.
            anonymous_ancestors = publisher.class.ancestors.select { |ancestor| ancestor.name.blank? }
            anonymous_ancestors.map!(&:to_s)
          end

          anonymous_ancestors.include?(klass)
        else
          publisher.class.ancestors.include?(klass)
        end
      end
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

    def normalize_classes(classes)
      classes = classes.dup
      classes.map! do |klass|
        next klass if klass.is_a?(Module)

        klass = klass.to_s

        begin
          Object.const_get(klass)
        rescue NameError
          klass
        end
      end
      classes.select!(&:present?)
      classes.uniq!
      classes
    end
  end
end
