# frozen_string_literal: true

module Wisper
  module Broadcasters
    describe SendBroadcaster do
      let(:listener) { double('listener') }
      let(:event)      { 'thing_created' }

      describe '#broadcast' do
        context 'without arguments' do
          it 'sends event to listener without any arguments' do
            expect(listener).to receive(event).with(no_args)
            subject.broadcast(listener, anything, event)
          end
        end

        context 'with empty arguments' do
          let(:args) { [] }

          it 'sends event to listener without any arguments' do
            expect(listener).to receive(event).with(no_args)
            subject.broadcast(listener, anything, event, *args)
          end
        end

        context 'with arguments' do
          context 'with only positional arguments' do
            let(:args) { [1, 2, 3] }

            it 'sends event to listener with arguments' do
              expect(listener).to receive(event).with(1, 2, 3)
              subject.broadcast(listener, anything, event, *args)
            end
          end

          context 'with only keyword arguments' do
            let(:kwargs) { { key: 'value' } }

            it 'sends event to listener with arguments' do
              expect(listener).to receive(event).with({ key: 'value' })
              subject.broadcast(listener, anything, event, **kwargs)
            end
          end

          context 'with positional and keyword arguments' do
            let(:args) { [1, 2, 3] }
            let(:kwargs) { { key: 'value' } }

            it 'sends event to listener with arguments' do
              expect(listener).to receive(event).with(1, 2, 3, { key: 'value' })
              subject.broadcast(listener, anything, event, *args, **kwargs)
            end
          end
        end
      end
    end
  end
end
