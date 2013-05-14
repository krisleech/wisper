require 'delegate'

module Wisper
  module Publisher
    class Listeners < SimpleDelegator
      attr_reader :publisher
      private     :publisher

      def initialize(publisher, registrations, &block)
        @publisher = publisher
        super(registrations.map(&:listener))
        freeze
        instance_eval &block if block_given?
      end

      def add(listeners, options = {})
        Array(listeners).each do |listener|
          publisher.add_listener(listener, options)
        end
        publisher.listeners # return the now mutated version, not self
      end
    end
  end
end
