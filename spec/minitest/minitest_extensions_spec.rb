require_relative '../minitest_helper'
require 'wisper/minitest/stub_wisper_publisher'

describe Wisper do
  describe "given a piece of code invoking a publisher" do
    class CodeThatReactsToEvents
      def do_something
        publisher = MyPublisher.new
        publisher.on(:some_event) do |variable1, variable2|
          return "Hello with #{variable1} #{variable2}!"
        end
        publisher.execute
      end
    end

    describe "when stubbing the publisher to emit an event" do
      it "emits the event" do
        silence_warnings do
          CodeThatReactsToEvents.stub_wisper_publisher("MyPublisher", :execute, :some_event, "foo1", "foo2") do
            response = CodeThatReactsToEvents.new.do_something
            response.must_equal "Hello with foo1 foo2!"
          end
        end
      end
    end
  end
end
