require 'set'
require 'wisper/version'
require 'wisper/configuration'
require 'wisper/publisher'
require 'wisper/value_objects/prefix'
require 'wisper/value_objects/events'
require 'wisper/registration/registration'
require 'wisper/registration/object'
require 'wisper/registration/block'
require 'wisper/global_listeners'
require 'wisper/temporary_listeners'
require 'wisper/broadcasters/send_broadcaster'
require 'wisper/broadcasters/logger_broadcaster'

module Wisper
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
  def self.subscribe(*args, **kwargs, &block)
    if block_given?
      TemporaryListeners.subscribe(*args, **kwargs, &block)
    else
      GlobalListeners.subscribe(*args, **kwargs)
    end
  end

  def self.unsubscribe(*listeners)
    GlobalListeners.unsubscribe(*listeners)
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
