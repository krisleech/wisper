module Wisper
  module Publisher
    def listeners
      registrations.map(&:listener).freeze
    end

    # subscribe a listener
    #
    # @example
    #   my_publisher.subscribe(MyListener.new)
    #
    # @return [self]
    def subscribe(listener, options = {})
      raise ArgumentError, "#{__method__} does not take a block, did you mean to call #on instead?" if block_given?
      add_local_registration(ObjectRegistration.new(listener, options))
      self
    end

    # subscribe a block
    #
    # @example
    #   my_publisher.on(:order_created) { |args| ... }
    #
    # @return [self]
    def on(*events, &block)
      raise ArgumentError, 'must give at least one event' if events.empty?
      raise ArgumentError, 'must pass a block' if !block
      add_local_registration(BlockRegistration.new(block, on: events))
      self
    end

    # broadcasts an event
    #
    # @example
    #   def call
    #     # ...
    #     broadcast(:finished, self)
    #   end
    #
    # @return [self]
    def broadcast(event, *args)
      registrations.each do | registration |
        registration.broadcast(clean_event(event), self, *args)
      end
      self
    end

    alias :publish :broadcast

    private :broadcast, :publish

    module ClassMethods
      # subscribe a listener
      #
      # @example
      #   MyPublisher.subscribe(MyListener.new)
      #
      def subscribe(listener, options = {})
        GlobalListeners.subscribe(listener, options.merge(:scope => self))
      end
    end

    private

    def local_registrations
      if defined? @local_registrations
        @local_registrations
      else
        Set.new
      end
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

    def add_local_registration(registration)
      raise ArgumentError, 'only global subscriptions available on frozen publisher objects' if frozen?
      @local_registrations ||= Set.new
      @local_registrations << registration
    end

    def clean_event(event)
      event.to_s.gsub('-', '_')
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
