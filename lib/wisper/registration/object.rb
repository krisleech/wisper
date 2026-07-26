# frozen_string_literal: true

module Wisper
  # A registration created by {Publisher#subscribe},
  # {GlobalListeners#subscribe} or {TemporaryListeners#subscribe},
  # wrapping an object listener.
  #
  # Handles the full set of subscription options: mapping the broadcast
  # event to a listener method (`:with`, `:prefix`), scoping to a
  # publisher class (`:scope`), and choosing which broadcaster delivers
  # the event (`:broadcaster`/`:async`).
  #
  # @api private
  class ObjectRegistration < Registration
    # @return [Symbol, String, nil] the method to call on the listener
    #   instead of the event name, if given
    attr_reader :with

    # @return [ValueObjects::Prefix] the prefix applied to the event name
    #   when mapping it to a listener method
    attr_reader :prefix

    # @return [Set<String>] publisher class names (by `#to_s`) this
    #   registration is scoped to; empty means unscoped (all publishers)
    attr_reader :allowed_classes

    # @return [#broadcast] the broadcaster used to deliver events to the
    #   listener
    attr_reader :broadcaster

    # @param listener [Object] the listener being registered
    # @param options [Hash]
    # @option options [nil, String, Symbol, Array, Regexp] :on (see {Registration#initialize})
    # @option options [Symbol, String] :with method to call on the
    #   listener instead of the event name
    # @option options [true, nil, #to_s] :prefix prepended to the mapped
    #   method name; see {ValueObjects::Prefix}
    # @option options [Class, String, Symbol, Array] :scope restricts
    #   this registration to publishers whose class (or an ancestor)
    #   matches
    # @option options [true, Symbol, #broadcast] :broadcaster (also
    #   aliased as `:async`) selects a broadcaster registered via
    #   {Configuration#broadcaster}, or is used directly if it responds
    #   to `#broadcast`
    def initialize(listener, **options)
      super
      @with   = options[:with]
      @prefix = ValueObjects::Prefix.new options[:prefix]
      @allowed_classes = Array(options[:scope]).to_set(&:to_s)
      @broadcaster = map_broadcaster(options[:async] || options[:broadcaster])
    end

    # Delivers the event to the listener, via {#broadcaster}, provided
    # the listener is subscribed to it, responds to the mapped method,
    # and the publisher is in scope.
    #
    # @param event [Symbol, String] the (cleaned) broadcast event
    # @param publisher [Object] the publisher which broadcast the event
    # @param args [Array] positional arguments to pass to the listener
    # @param kwargs [Hash] keyword arguments to pass to the listener
    #
    # @return [Object, nil] the broadcaster's return value, or nil if
    #   this registration does not apply
    def broadcast(event, publisher, *, **)
      method_to_call = map_event_to_method(event)
      return unless should_broadcast?(event) && listener.respond_to?(method_to_call) && publisher_in_scope?(publisher)

      broadcaster.broadcast(listener, publisher, method_to_call, *, **)
    end

    private

    def publisher_in_scope?(publisher)
      allowed_classes.empty? || publisher.class.ancestors.any? { |ancestor| allowed_classes.include?(ancestor.to_s) }
    end

    def map_event_to_method(event)
      prefix + (with || event).to_s
    end

    def map_broadcaster(value)
      return value if value.respond_to?(:broadcast)

      value = :async   if value == true
      value = :default if value.nil?
      configuration.broadcasters.fetch(value)
    end

    def configuration
      Wisper.configuration
    end
  end
end
