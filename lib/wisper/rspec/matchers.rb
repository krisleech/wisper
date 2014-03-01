require 'rspec/expectations'

module WisperMatchers
  class ShouldPublish
    def initialize(publisher, event)
      @publisher = publisher
      @event = event
    end

    def matches?(block)
      published = false
      @publisher.on(@event) { published = true }

      block.call

      published
    end

    def failure_message_for_should
      "expected #{@publisher.class.name} to broadcast #{@event} event"
    end

    def failure_message_for_should_not
      "expected #{@publisher.class.name} not to broadcast #{@event} event"
    end
  end

  def publish_event(publisher, event)
    ShouldPublish.new(publisher, event)
  end

  alias broadcast publish_event
end

RSpec::configure do |config|
  config.include(WisperMatchers)
end