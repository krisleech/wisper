module Wisper
  module Broadcasters
    class Base
      extend Forwardable

      attr_reader :options, :registration

      def_delegators :registration, :listener, :method_name

      def initialize(registration, options = {})
        @registration = registration
        @options = options
      end

      def should_broadcast?(event, _)
        on.include?(event) || on.include?('all')
      end

      protected

      def on
        @on ||= Array(options.fetch(:on){ 'all' }).map(&:to_s)
      end
    end
  end
end
