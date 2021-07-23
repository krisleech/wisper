module Wisper
  module Broadcasters

    describe LoggerBroadcaster do

      describe 'integration tests:' do
        let(:publisher) { publisher_class.new }
        let(:listener)  { double }
        let(:logger)    { double.as_null_object }

        context 'with only positional arguments' do
          it 'broadcasts the event to the listener' do
            publisher.subscribe(listener, :broadcaster => LoggerBroadcaster.new(logger, Wisper::Broadcasters::SendBroadcaster.new))
            if RUBY_VERSION < '3.0'
              # Ruby 2.7 receives **{} as a positional argument
              expect(listener).to receive(:it_happened).with(1, 2, {})
            else
              # Ruby 3.0 doesn't pass **empty_hash
              expect(listener).to receive(:it_happened).with(1, 2)
            end
            publisher.send(:broadcast, :it_happened, 1, 2)
          end
        end

        context 'with only keyword arguments' do
          it 'broadcasts the event to the listener' do
            publisher.subscribe(listener, :broadcaster => LoggerBroadcaster.new(logger, Wisper::Broadcasters::SendBroadcaster.new))
            expect(listener).to receive(:it_happened).with(key: 'value')
            publisher.send(:broadcast, :it_happened, key: 'value')
          end
        end

        context 'with positional and keyword arguments' do
          it 'broadcasts the event to the listener' do
            publisher.subscribe(listener, :broadcaster => LoggerBroadcaster.new(logger, Wisper::Broadcasters::SendBroadcaster.new))
            expect(listener).to receive(:it_happened).with(1, 2, key: 'value')
            publisher.send(:broadcast, :it_happened, 1, 2, key: 'value')
          end
        end
      end

      describe 'unit tests:' do
        let(:publisher)   { classy_double('Publisher',  id: 1) }
        let(:listener)  { classy_double('Listener', id: 2) }
        let(:logger)      { double('Logger').as_null_object }
        let(:broadcaster) { double('Broadcaster').as_null_object }
        let(:event)       { 'thing_created' }

        subject           { LoggerBroadcaster.new(logger, broadcaster) }

        describe '#broadcast' do
          context 'without arguments' do
            let(:args) { [] }
            let(:kwargs) { {} }

            it 'logs published event' do
              expect(logger).to receive(:info).with('[WISPER] Publisher#1 published thing_created to Listener#2 with no arguments and no keyword arguments')
              subject.broadcast(listener, publisher, event, *args, **kwargs)
            end

            it 'delegates broadcast to a given broadcaster' do
              expect(broadcaster).to receive(:broadcast).with(listener, publisher, event, *args, **kwargs)
              subject.broadcast(listener, publisher, event, *args, **kwargs)
            end
          end

          context 'with arguments' do
            let(:args) { [arg_double(id: 3), arg_double(id: 4)] }
            let(:kwargs) { {x: :y} }

            it 'logs published event and arguments' do
              expect(logger).to receive(:info).with("[WISPER] Publisher#1 published thing_created to Listener#2 with Argument#3, Argument#4 and keyword arguments {:x=>:y}")
              subject.broadcast(listener, publisher, event, *args, **kwargs)
            end

            it 'delegates broadcast to a given broadcaster' do
              expect(broadcaster).to receive(:broadcast).with(listener, publisher, event, *args, **kwargs)
              subject.broadcast(listener, publisher, event, *args, **kwargs)
            end

            context 'when argument is a hash' do
              let(:args) { [hash] }
              let(:hash) { {key: 'value'} }
              let(:kwargs) { {x: :y} }

              it 'logs published event and arguments' do
                expect(logger).to receive(:info).with("[WISPER] Publisher#1 published thing_created to Listener#2 with Hash##{hash.object_id}: #{hash.inspect} and keyword arguments {:x=>:y}")
                subject.broadcast(listener, publisher, event, *args, **kwargs)
              end
            end

            context 'when argument is an integer' do
              let(:args) { [number] }
              let(:number) { 10 }

              it 'logs published event and arguments' do
                expect(logger).to receive(:info).with("[WISPER] Publisher#1 published thing_created to Listener#2 with #{number.class.name}##{number.object_id}: 10 and keyword arguments {:x=>:y}")
                subject.broadcast(listener, publisher, event, *args, **kwargs)
              end
            end

            context 'when only keyword arguments are present' do
              let(:args) { [] }

              it 'logs published event and arguments' do
                expect(logger).to receive(:info).with("[WISPER] Publisher#1 published thing_created to Listener#2 with no arguments and keyword arguments {:x=>:y}")
                subject.broadcast(listener, publisher, event, *args, **kwargs)
              end
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
