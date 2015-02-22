RSpec.describe Wisper do
  let(:listener)   { double('Listener') }
  let(:publisher)  { publisher_class.new }
  let(:event_name) { 'some_event' }

  describe '.subscribe' do
    describe 'without block' do

      it 'subscribes given listener to every publisher' do
        Wisper.subscribe(listener)
        expect(listener).to receive(event_name)
        publisher.send(:broadcast, event_name)
      end
    end # without block

    describe 'with block' do

      it 'subscribes listeners to all events for duration of the block' do
        expect(listener).to receive(:first_event)
        expect(listener).not_to receive(:second_event)

        Wisper.subscribe(listener) do
          publisher.send(:broadcast, 'first_event')
        end

        publisher.send(:broadcast, 'second_event')
      end

      it 'clears registrations when an exception occurs' do
        MyError = Class.new(StandardError)

        begin
          Wisper::TemporaryListeners.subscribe(listener) do
            raise MyError
          end
        rescue MyError
        end

        expect(Wisper::TemporaryListeners.registrations).to be_empty
      end
    end # with block
  end # .subscribe

  describe '.clear' do
    before { Wisper.subscribe(double) }

    it 'clears all global listeners' do
      Wisper.clear
      expect(Wisper::GlobalListeners.listeners).to be_empty
    end
  end # .clear
end
