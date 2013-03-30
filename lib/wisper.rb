require "wisper/version"

module Wisper
  def listeners
    @listeners ||= Set.new
  end

  def add_listener(listener, options = {})
    listeners << ObjectRegistration.new(listener, options)
  end

  def add_block_listener(options = {}, &block)
    listeners << BlockRegistration.new(block, options)
  end

  # sugar
  def respond_to(event, &block)
    listeners << BlockRegistration.new(block, :on => event)
  end

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
