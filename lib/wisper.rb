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
    TemporaryListeners.with(*args, &block)
  end

  def self.add_listener(listener, options = {})
    GlobalListeners.add(listener, options)
  end
end
