require "wisper/version"
require "wisper/registration/registration"
require "wisper/registration/object"
require "wisper/registration/block"
require 'wisper/global_listeners'

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

  def all_listeners
    listeners.merge(GlobalListeners.listeners)
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
