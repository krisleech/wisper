# frozen_string_literal: true

module Wisper
  # Include this module in any class to give its instances
  # Publish-Subscribe capabilities: instances can have listeners
  # {#subscribe}d to them, and can {#broadcast} (privately) events which
  # those listeners will be notified of.
  #
  # @example
  #   class CancelOrder
  #     include Wisper::Publisher
  #
  #     def call(order_id)
  #       # ...
  #       broadcast(:cancel_order_successful, order_id)
  #     end
  #   end
  #
  #   CancelOrder.new.tap { |c| c.subscribe(OrderNotifier.new) }.call(1)
  module Publisher
    # @return [Array<Object>] the listeners subscribed directly to this
    #   publisher instance (i.e. excluding global/temporary listeners),
    #   frozen
    def listeners
      registrations.map(&:listener).freeze
    end

    # Subscribes a listener object to this publisher instance only.
    #
    # @param listener [Object] the listener to subscribe
    # @param options [Hash] see {ObjectRegistration#initialize} for the
    #   full set of supported options (`:on`, `:with`, `:prefix`,
    #   `:scope`, `:broadcaster`/`:async`)
    # @raise [ArgumentError] if called with a block (use {#on} instead)
    #
    # @example
    #   my_publisher.subscribe(MyListener.new)
    #
    # @return [self]
    def subscribe(listener, **)
      raise ArgumentError, "#{__method__} does not take a block, did you mean to call #on instead?" if block_given?

      local_registrations << ObjectRegistration.new(listener, **)
      self
    end

    # Subscribes a block to one or more events on this publisher
    # instance. Can be chained.
    #
    # @param events [Array<Symbol, String>] the event(s) the block should
    #   be called for
    # @raise [ArgumentError] if no events, or no block, are given
    #
    # @example
    #   my_publisher.on(:order_created) { |args| ... }
    #
    # @return [self]
    def on(*events, &block)
      raise ArgumentError, 'must give at least one event' if events.empty?
      raise ArgumentError, 'must pass a block' unless block

      local_registrations << BlockRegistration.new(block, on: events)
      self
    end

    # Broadcasts an event to every listener subscribed to this publisher
    # (directly, globally, or temporarily), in registration order.
    #
    # This method (and its `publish` alias) is private; call it from
    # within the publisher itself.
    #
    # @param event [Symbol, String] the event name. Dashes are treated
    #   the same as underscores.
    # @param args [Array] positional arguments passed to each listener
    # @param kwargs [Hash] keyword arguments passed to each listener
    #
    # @example
    #   def call
    #     # ...
    #     broadcast(:finished, self)
    #   end
    #
    # @return [self]
    def broadcast(event, *args, **kwargs)
      registrations.each do |registration|
        registration.broadcast(clean_event(event), self, *args, **kwargs)
      end
      self
    end

    alias publish broadcast

    private :broadcast, :publish

    # Class-level API mixed into any class which includes {Publisher},
    # allowing listeners to subscribe globally to every instance of that
    # class (and its subclasses).
    module ClassMethods
      # Subscribes a listener to every instance of this publisher class
      # (and subclasses), equivalent to `Wisper.subscribe(listener,
      # scope: self)`.
      #
      # @param listener [Object] the listener to subscribe
      # @param options [Hash] see {ObjectRegistration#initialize}
      #
      # @example
      #   MyPublisher.subscribe(MyListener.new)
      #
      # @return [Object] the return value of {GlobalListeners.subscribe}
      def subscribe(listener, **)
        GlobalListeners.subscribe(listener, **, scope: self)
      end
    end

    # @api private
    def self.included(base)
      base.extend(ClassMethods)
    end

    private

    def local_registrations
      @local_registrations ||= Set.new
    end

    def global_registrations
      GlobalListeners.registrations
    end

    def temporary_registrations
      TemporaryListeners.registrations
    end

    def registrations
      local_registrations + global_registrations + temporary_registrations
    end

    def clean_event(event)
      event.to_s.tr('-', '_')
    end
  end
end
