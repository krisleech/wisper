require "wisper/version"
require "wisper/registration/object"
require "wisper/registration/block"

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
