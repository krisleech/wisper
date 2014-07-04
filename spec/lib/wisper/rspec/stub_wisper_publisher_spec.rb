require 'wisper/rspec/stub_wisper_publisher'

describe '#stub_wisper_publisher' do
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

    context "when stubbing the publisher to emit an event" do
      before do
        stub_wisper_publisher("MyPublisher", :execute, :some_event, "foo1", "foo2")
      end

      it "emits the event" do
        response = CodeThatReactsToEvents.new.do_something
        expect(response).to eq "Hello with foo1 foo2!"
      end
    end
  end
end
