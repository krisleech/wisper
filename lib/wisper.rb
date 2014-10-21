require 'set'
require 'wisper/version'
require 'wisper/configuration'
require 'wisper/publisher'
require 'wisper/registration/registration'
require 'wisper/registration/object'
require 'wisper/registration/block'
require 'wisper/global_listeners'
require 'wisper/temporary_listeners'
require 'wisper/broadcasters/send_broadcaster'
require 'wisper/broadcasters/logger_broadcaster'

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

  # Examples:
  #
  #   Wisper.subscribe(AuditRecorder.new)
  #
  #   Wisper.subscribe(AuditRecorder.new, StatsRecorder.new)
  #
  #   Wisper.subscribe(AuditRecorder.new, on: 'order_created')
  #
  #   Wisper.subscribe(AuditRecorder.new, scope: 'MyPublisher')
  #
  #   Wisper.subscribe(AuditRecorder.new, StatsRecorder.new) do
  #     # ..
  #   end
  #
  def self.subscribe(*args, &block)
    if block_given?
      TemporaryListeners.subscribe(*args, &block)
    else
      GlobalListeners.subscribe(*args)
    end
  end

  def self.publisher
    Publisher
  end

  def self.clear
    GlobalListeners.clear
  end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup
    configure do |config|
      config.broadcaster(:default, Broadcasters::SendBroadcaster.new)
    end
  end
end

Wisper.setup
