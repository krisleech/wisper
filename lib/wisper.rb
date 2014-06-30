require 'set'
require 'wisper/version'
require 'wisper/config'
require 'wisper/global_listeners'
require 'wisper/temporary_listeners'
require 'wisper/publisher'
require 'wisper/registration'
require 'wisper/broadcasters/base'
require 'wisper/broadcasters/block'
require 'wisper/broadcasters/direct_invocation'

module Wisper
  def self.included(base)
    warn "[DEPRECATION] `include Wisper::Publisher` instead of `include Wisper`"
    base.class_eval { include Wisper::Publisher  }
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end

  def self.with_listeners(*args, &block)
    TemporaryListeners.with(*args, &block)
  end

  def self.add_listener(listener, options = {})
    GlobalListeners.add(listener, options)
  end
end
