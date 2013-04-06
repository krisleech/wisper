require "wisper/version"

module Wisper
  def listeners
    @listeners ||= Set.new
  end

  def add_listener(listener, options = {})
    listeners << ObjectRegistration.new(listener, options)
    self
  end

  alias :subscribe :add_listener

  def add_block_listener(options = {}, &block)
    listeners << BlockRegistration.new(block, options)
    self
  end

  # sugar
  def respond_to(event, &block)
    add_block_listener({:on => event}, &block)
  end

  alias :on :respond_to

  class BlockRegistration
    attr_reader :on, :listener

    def initialize(block, options)
      @listener   = block
      @on = Array(options.fetch(:on) { 'all' }).map(&:to_s)
    end

    def broadcast(event, *args)
      if on.include?(event) || on.include?('all')
        listener.call(*args)
      end
    end
  end

  class ObjectRegistration
    attr_reader :on, :with, :listener

    def initialize(listener, options)
      @listener   = listener
      @method     = options[:method]
      @on = Array(options.fetch(:on) { 'all' }).map(&:to_s)
      @with = options[:with]
    end

    def broadcast(event, *args)
      method_to_call = map_event_to_method(event)
      if should_broadcast?(event) && listener.respond_to?(method_to_call)
        listener.public_send(method_to_call, *args)
      end
    end

    private

    def should_broadcast?(event)
      on.include?(event) || on.include?('all')
    end

    def map_event_to_method(event)
      self.with || event
    end

  end

  private

  def broadcast(event, *args)
    listeners.each do | listener |
      listener.broadcast(clean_event(event), *args) 
    end
  end

  alias :publish  :broadcast
  alias :announce :broadcast

  def clean_event(event)
    event.to_s.gsub('-', '_')
  end
end
