module Wisper
  module Publisher
    def listeners
      all_listeners.dup.freeze
    end

    def add_listener(listener, options = {})
      local_listeners << ObjectRegistration.new(listener, options)
      self
    end

    alias :subscribe :add_listener

    def add_block_listener(options = {}, &block)
      local_listeners << BlockRegistration.new(block, options)
      self
    end

    # sugar
    def respond_to(event, &block)
      add_block_listener({:on => event}, &block)
    end

    alias :on :respond_to

    private

    def local_listeners
      @local_listeners ||= Set.new
    end

    def global_listeners
      GlobalListeners.listeners
    end

    def all_listeners
      local_listeners.merge(global_listeners)
    end

    def broadcast(event, *args)
      all_listeners.each do | listener |
        listener.broadcast(clean_event(event), *args)
      end
    end

    alias :publish  :broadcast
    alias :announce :broadcast

    def clean_event(event)
      event.to_s.gsub('-', '_')
    end
  end
end

