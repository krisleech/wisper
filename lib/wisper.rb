# frozen_string_literal: true

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

# Wisper provides Ruby objects with Publish-Subscribe capabilities.
#
# Include {Wisper::Publisher} in any class to let its instances broadcast
# events to listeners which subscribe to them, either per-instance
# ({Wisper::Publisher#subscribe}) or globally (+Wisper.subscribe+).
#
# @see https://github.com/krisleech/wisper/wiki the wiki for further guides
#   and examples
module Wisper
  # Subscribes one or more listeners.
  #
  # With no block, the listeners are subscribed globally (equivalent to
  # {GlobalListeners.subscribe}) until explicitly {unsubscribe}d.
  #
  # With a block, the listeners are subscribed globally only for the
  # duration of the block, on the current thread (equivalent to
  # {TemporaryListeners.subscribe}).
  #
  # @param listeners [Array<Object>] one or more listener objects
  # @param options [Hash] see {ObjectRegistration#initialize} for the
  #   full set of supported options (`:on`, `:with`, `:prefix`, `:scope`,
  #   `:broadcaster`/`:async`)
  #
  # @example subscribe a single listener globally
  #   Wisper.subscribe(AuditRecorder.new)
  #
  # @example subscribe multiple listeners globally
  #   Wisper.subscribe(AuditRecorder.new, StatsRecorder.new)
  #
  # @example subscribe to a single event only
  #   Wisper.subscribe(AuditRecorder.new, on: 'order_created')
  #
  # @example subscribe scoped to a publisher class
  #   Wisper.subscribe(AuditRecorder.new, scope: 'MyPublisher')
  #
  # @example subscribe for the duration of a block only
  #   Wisper.subscribe(AuditRecorder.new, StatsRecorder.new) do
  #     # ..
  #   end
  #
  # @return [Object] the return value of {TemporaryListeners.subscribe} or
  #   {GlobalListeners.subscribe}
  def self.subscribe(*, **, &)
    if block_given?
      TemporaryListeners.subscribe(*, **, &)
    else
      GlobalListeners.subscribe(*, **)
    end
  end

  # Removes one or more listeners from the global listeners.
  #
  # @param listeners [Array<Object>] the listener(s) previously passed to
  #   {subscribe}
  #
  # @return [GlobalListeners]
  def self.unsubscribe(*listeners)
    GlobalListeners.unsubscribe(*listeners)
  end

  # @return [Module] the {Publisher} module, so it can be included via
  #   `include Wisper.publisher` as an alternative to `include
  #   Wisper::Publisher`
  def self.publisher
    Publisher
  end

  # Removes all global listeners.
  #
  # @return [GlobalListeners]
  def self.clear
    GlobalListeners.clear
  end

  # Yields the global {Configuration} instance for modification.
  #
  # @example
  #   Wisper.configure do |config|
  #     config.broadcaster(:async, MyAsyncBroadcaster.new)
  #   end
  #
  # @yieldparam configuration [Configuration]
  # @return [void]
  def self.configure
    yield(configuration)
  end

  # @return [Configuration] the memoized global configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Restores the default configuration, registering
  # {Broadcasters::SendBroadcaster} as the `:default` broadcaster.
  #
  # @api private
  # @return [void]
  def self.setup
    configure do |config|
      config.broadcaster(:default, Broadcasters::SendBroadcaster.new)
    end
  end
end

Wisper.setup
