module Wisper
  module Broadcasters
    class DirectInvocation < Base
      def broadcast_event(event, _, args)
        listener.public_send(method_name(event), *args)
      end

      def should_broadcast?(event, publisher)
        super(event, publisher) && listener.respond_to?(method_name(event)) && publisher_in_scope?(publisher)
      end

      protected

      def publisher_in_scope?(publisher)
        allowed_classes.empty? || publisher.class.ancestors.any? { |ancestor| allowed_classes.include?(ancestor.to_s) }
      end

      def allowed_classes
        @allowed_classes = Array(options[:scope]).map(&:to_s).to_set
      end
    end
  end
end
