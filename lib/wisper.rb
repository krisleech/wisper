require "wisper/version"

module Wisper
  def listeners
    @listeners ||= Set.new
  end

  def add_listener(listener, options = {})
    listeners << ObjectRegistration.new(listener, options)
  end

  alias :subscribe :add_listener

  def add_block_listener(options = {}, &block)
    listeners << BlockRegistration.new(block, options)
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
    attr_reader :on, :listener

    def initialize(listener, options)
      @listener   = listener
      @method     = options[:method]
      @on = Array(options.fetch(:on) { 'all' }).map(&:to_s)
    end

    def broadcast(event, *args)
      if (on.include?(event) || on.include?('all')) && listener.respond_to?(event)
        listener.public_send(event, *args) 
      end
    end

    alias :publish  :broadcast
    alias :announce :broadcast
  end

  private

  def broadcast(event, *args)
    listeners.each do | listener |
      listener.broadcast(clean_event(event), *args) 
    end
  end

  def clean_event(event)
    event.to_s.gsub('-', '_')
  end
end
