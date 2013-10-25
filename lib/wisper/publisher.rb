module Wisper
  module Publisher
    def listeners
      registrations.map(&:listener).freeze
    end

    def add_listener(listener, options = {})
      local_registrations << ObjectRegistration.new(listener, options)
      self
    end

    alias :subscribe :add_listener

    def add_block_listener(options = {}, &block)
      local_registrations << BlockRegistration.new(block, options)
      self
    end

    # sugar
    def respond_to(*events, &block)
      add_block_listener({:on => events}, &block)
    end

    alias :on :respond_to

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
      registrations.each do | registration |
        registration.broadcast(clean_event(event), *args) rescue nil
      end
    end

    alias :publish  :broadcast
    alias :announce :broadcast

    def clean_event(event)
      event.to_s.gsub('-', '_')
    end
  end
end

