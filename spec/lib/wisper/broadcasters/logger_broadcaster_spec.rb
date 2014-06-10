module Wisper
  module Broadcasters

    describe LoggerBroadcaster do

      describe 'integration tests:' do
        let(:publisher) { publisher_class.new }
        let(:listener)  { double }
        let(:logger)    { double.as_null_object }

        it 'broadcasts the event to the listener' do
          publisher.subscribe(listener, :broadcaster => LoggerBroadcaster.new(logger, Wisper::Broadcasters::SendBroadcaster.new))
          expect(listener).to receive(:it_happened).with(1, 2)
          publisher.send(:broadcast, :it_happened, 1, 2)
        end
      end

      describe 'unit tests:' do
        let(:publisher)   { classy_double('Publisher',  id: 1) }
        let(:subscriber)  { classy_double('Subscriber', id: 2) }
        let(:logger)      { double('Logger').as_null_object }
        let(:broadcaster) { double('Broadcaster').as_null_object }
        let(:event)       { 'thing_created' }

        subject           { LoggerBroadcaster.new(logger, broadcaster) }

        describe '#broadcast' do
          context 'without arguments' do
            let(:args) { [] }

            it 'logs publised event' do
              expect(logger).to receive(:info).with('[WISPER] Publisher#1 published thing_created to Subscriber#2 with no arguments')
              subject.broadcast(subscriber, publisher, event, args)
            end

            it 'delgates broadcast to given broadcaster' do
              expect(broadcaster).to receive(:broadcast).with(subscriber, publisher, event, args)
              subject.broadcast(subscriber, publisher, event, args)
            end
          end

          context 'with arguments' do
            let(:args) { [arg_double(id: 3), arg_double(id: 4)] }

            it 'logs published event and arguments' do
              expect(logger).to receive(:info).with('[WISPER] Publisher#1 published thing_created to Subscriber#2 with Argument#3, Argument#4')
              subject.broadcast(subscriber, publisher, event, args)
            end

            it 'delgates broadcast to given broadcaster' do
              expect(broadcaster).to receive(:broadcast).with(subscriber, publisher, event, args)
              subject.broadcast(subscriber, publisher, event, args)
            end
          end

        end

        # provides a way to specify `double.class.name` easily
        def classy_double(klass, options)
          double(klass, options.merge(class: double_class(klass)))
        end

        def arg_double(options)
          classy_double('Argument', options)
        end

        def double_class(name)
          double(name: name)
        end
      end
    end
  end
end
