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

# The Wisper module, used for global subscriptions and configuration

module Wisper
  # @api private
  def self.included(base)
    warn "[DEPRECATION] `include Wisper::Publisher` instead of `include Wisper`"
    base.class_eval { include Wisper::Publisher  }
  end

  # Subscribes a listener globally, temporarily
  # @deprecated Use {#subscribe} instead.
  def self.with_listeners(*args, &block)
    warn "[DEPRECATION] `use Wisper.subscribe` instead of `Wisper.with_listeners`"
    self.subscribe(*args, &block)
  end

  # Subscribes a listener globally, permanently
  # @deprecated Use {#subscribe} instead.
  def self.add_listener(listener, options = {})
    warn "[DEPRECATION] `use Wisper.subscribe` instead of `Wisper.add_listener`"
    self.subscribe(listener, options)
  end

  # Subscribes a listener globally, either permanently or temporarily
  #
  # @overload subscribe(*listeners, options = {})
  #   Subscribes listeners globally, to every publisher
  #   @param listeners [Object] the listeners, of any object, to subscribe
  #   @param options [Hash] an optional hash of options
  #
  # @overload subscribe(*listeners, options = {}, &block)
  #   Subscribes listeners globally, to every publisher, for the duration of the block
  #   @param listeners [Object] the listeners, of any object, to subscribe
  #   @param options [Hash] an optional hash of options
  #   @yield the block in which the listener is globally subscribed
  #
  # @note see README for all options
  #
  # @return [Wisper]
  def self.subscribe(*args, &block)
    if block_given?
      TemporaryListeners.with(*args, &block)
    else
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |listener|
        GlobalListeners.add(listener, options)
      end
    end
    self
  end

  # The module to be included in a publisher
  # @example
  #   include Wisper.publisher
  #
  # @return [Publisher] the publisher module
  def self.publisher
    Publisher
  end

  # Clears all global listeners.
  #
  # @note This is usually only used in tests
  #
  # @example
  #   Wisper.clear
  #
  # @return [Wisper]
  def self.clear
    GlobalListeners.clear
    self
  end

  # Provides access by way of a block to the configuration
  # @yield [configuration] Gives the configuration to the block
  # @example
  #   Wisper.configure do |config|
  #     # ...
  #   end
  def self.configure
    yield(configuration)
  end

  # The Wisper configuration
  # @return [Configuration]
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Sets up Wisper default configuration
  # @note There is no need to call this method yourself
  # @api private
  def self.setup
    configure do |config|
      config.broadcaster(:default, Broadcasters::SendBroadcaster.new)
    end
  end
end

Wisper.setup
