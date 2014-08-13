require 'set'
require 'wisper/version'
require 'wisper/publisher'
require 'wisper/registration/registration'
require 'wisper/registration/object'
require 'wisper/registration/block'
require 'wisper/global_listeners'
require 'wisper/temporary_listeners'

module Wisper
  def self.included(base)
    warn "[DEPRECATION] `include Wisper::Publisher` instead of `include Wisper`"
    base.class_eval { include Wisper::Publisher  }
  end

  def self.with_listeners(*args, &block)
    warn "[DEPRECATION] `use Wisper.subscribe` instead of `Wisper.with_listeners`"
    self.subscribe(*args, &block)
  end

  def self.add_listener(listener, options = {})
    warn "[DEPRECATION] `use Wisper.subscribe` instead of `Wisper.add_listener`"
    self.subscribe(listener, options)
  end

  def self.subscribe(*args, &block)
    if block_given?
      TemporaryListeners.with(*args, &block)
    else
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |listener|
        GlobalListeners.add(listener, options)
      end
    end
  end
end
