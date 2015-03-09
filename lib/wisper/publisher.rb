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
    def subscribe(listener, options = {}, &block)
      local_registrations << ObjectRegistration.new(listener, options, &block)
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
      local_registrations << BlockRegistration.new(block, on: events)
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
        begin
          registration.broadcast(clean_event(event), self, *args)
        rescue => e
          raise e unless registration.error_handler

          payload = { event: clean_event(event), args: args, error: e }
          registration.error_handler.call(self, payload)
        end
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
      def subscribe(listener, options = {}, &block)
        GlobalListeners.subscribe(listener, options.merge(:scope => self), &block)
      end
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
      event.to_s.gsub('-', '_')
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
