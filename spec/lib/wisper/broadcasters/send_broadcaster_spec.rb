module Wisper
  module Broadcasters
    describe SendBroadcaster do
      let(:subscriber) { double('subscriber') }
      let(:event)      { 'thing_created' }

      describe '#broadcast' do
        context 'without arguments' do
          let(:args) { [] }

          it 'sends event to subscriber without any arguments' do
            expect(subscriber).to receive(event).with(no_args())
            subject.broadcast(subscriber, anything, event, args)
          end
        end

        context 'with arguments' do
          let(:args) { [1,2,3] }

          it 'sends event to subscriber with arguments' do
            expect(subscriber).to receive(event).with(*args)
            subject.broadcast(subscriber, anything, event, args)
          end
        end
      end
    end
  end
end
