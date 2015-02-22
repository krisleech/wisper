describe Wisper::Publisher do
  let(:listener)  { double('listener') }
  let(:publisher) { publisher_class.new }

  describe '#subscribe' do
    it 'registers listener as object' do
      expect(Wisper::ObjectRegistration).to receive(:new)
      publisher.subscribe(listener)
    end
  end

  describe '#on' do
    it 'registers listener as block' do
      expect(Wisper::BlockRegistration).to receive(:new)
      publisher.on(:an_event) {  }
    end

    it 'raises error if no events given' do
      expect { publisher.on() { } }.to raise_error(ArgumentError, 'must give at least one event')
    end
  end

  describe '.listeners' do
    it 'starts empty' do
      expect(publisher.listeners).to be_empty
    end

    it 'returns registered listeners' do
      publisher.subscribe(listener)
      expect(publisher.listeners).to include listener
    end
  end

  describe '.subscribe' do
    it 'globally subscribes listener scoped to publisher class' do
      expect(Wisper::GlobalListeners).to receive(:subscribe).with(listener, hash_including(scope: publisher.class))
      publisher.class.subscribe(listener)
    end
  end

  describe '#broadcast' do
    it 'is not public' do
      expect(listener).not_to respond_to(:broadcast)
    end


    it 'invokes broadcast on registrations' do
      publisher.subscribe(listener)
      expect_any_instance_of(Wisper::ObjectRegistration).to receive(:broadcast)
      publisher.send(:broadcast, :an_event)
    end

    describe 'invoking registrations' do
      before { publisher.subscribe(listener) }

      it 'arguments include event name' do
        expect_any_instance_of(Wisper::ObjectRegistration).to receive(:broadcast).with('an_event', anything)
        publisher.send(:broadcast, 'an_event')
      end

      it 'arguments include publisher' do
        expect_any_instance_of(Wisper::ObjectRegistration).to receive(:broadcast).with(anything, publisher)
        publisher.send(:broadcast, 'an_event')
      end

      it 'arguments include event args' do
        expect_any_instance_of(Wisper::ObjectRegistration).to receive(:broadcast).with(anything, anything, 1, 2, 3)
        publisher.send(:broadcast, 'an_event', 1, 2, 3)
      end

      context 'event name includes a dash' do
        it 'substitutes it for a underscore' do
          expect_any_instance_of(Wisper::ObjectRegistration).to receive(:broadcast).with('an_event', anything)
          publisher.send(:broadcast, 'an-event')
        end
      end
    end

  end
end
