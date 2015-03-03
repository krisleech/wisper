module Wisper
  module ValueObjects #:nodoc:
    # Describes allowed events
    #
    # Duck-types the argument to quack like array of strings
    # when responding to the {#include?} method call.
    class Events

      # List of methods to check event 'inclusion' acceptance for various types
      # of events definitions
      def methods
        {
          'NilClass' => ->(_event) { true },
          'String'   => ->(event)  { @list == event },
          'Symbol'   => ->(event)  { @list.to_s == event },
          'Array'    => ->(event)  { @list.map(&:to_s).include? event },
          'Regexp'   => ->(event)  { !!@list.match(event) }
        }.freeze
      end

      # @!scope class
      # @!method new(on)
      # Initializes a 'list' of events
      #
      # @param [NilClass, String, Symbol, Array, Regexp] list
      #
      # @raise [ArgumentError]
      #   if an argument if of unsupported type
      #
      # @return [undefined]
      def initialize(list)
        @list = list
      end

      # Check if given event is 'included' to the 'list' of events
      #
      # @param [#to_s] event
      #
      # @return [Boolean]
      def include?(event)
        check.call(event.to_s)
      end

      private

      def klass
        @klass ||= @list.class
      end

      def check
        methods.fetch(klass.name) do
          fail ArgumentError, "#{klass} not supported for `on` argument"
        end
      end
    end # class Events
  end # module ValueObjects
end # module Wisper
