require 'delegate'

# Provides read and write operations for a collection of listeners.
#
# Read operations are delegated to the collection of listeners
# Write operations are delegated to the provided data store, a new mutated
# object is returned. The store is either a publisher or an instance of
# GlobalListeners.

module Wisper
  module Publisher
    class Listeners < SimpleDelegator
      attr_reader :store
      private     :store

      def initialize(store, registrations, &block)
        @store = store
        super(registrations.map(&:listener))
        freeze
        instance_eval &block if block_given?
      end

      def add(listeners, options = {})
        Array(listeners).each do |listener|
          store.add_listener(listener, options)
        end
        store.listeners # return the now mutated version, not self
      end
    end
  end
end
