module Wisper
  module Publisher
    def listeners
      registrations.map(&:listener).freeze
    end

    def add_listener(listener, options = {})
      local_registrations << Registration.new(listener, options)
      self
    end

    alias :subscribe :add_listener

    def add_block_listener(options = {}, &block)
      local_registrations << Registration.new(block, options.merge(broadcaster: Broadcasters::Block))
      self
    end

    # sugar
    def respond_to(*events, &block)
      add_block_listener({:on => events}, &block)
    end

    alias :on :respond_to

    def skip_all_listeners
      old_skip_all, self.local_skip_all_listeners = local_skip_all_listeners?, true
      yield
    ensure
      self.local_skip_all_listeners = old_skip_all
    end

    module ClassMethods
      def add_listener(listener, options = {})
        GlobalListeners.add(listener, options.merge(:scope => self))
      end

      def skip_all_listeners
        old_skip_all, self.skip_all_listeners = skip_all_listeners?, true
        yield
      ensure
        self.skip_all_listeners = old_skip_all
      end

      def skip_all_listeners?
        !!Thread.current["__#{self.object_id}_temporary_skip_all_listeners"]
      end

      alias :subscribe :add_listener

      private

      def skip_all_listeners=(value)
        Thread.current["__#{self.object_id}_temporary_skip_all_listeners"] = value
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

    def broadcast(event, *args)
      return if skip_all_listeners?

      registrations.each do | registration |
        registration.broadcast(clean_event(event), self, *args)
      end
    end

    alias :publish  :broadcast
    alias :announce :broadcast

    def skip_all_listeners?
      Wisper.config.skip_all? ||
        Wisper.config.temporary_skip_all? ||
        self.class.skip_all_listeners? ||
        local_skip_all_listeners?
    end

    def local_skip_all_listeners=(value)
      Thread.current["__#{self.object_id}_temporary_skip_all_listeners"] = value
    end

    def local_skip_all_listeners?
      !!Thread.current["__#{self.object_id}_temporary_skip_all_listeners"]
    end

    def clean_event(event)
      event.to_s.gsub('-', '_')
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

