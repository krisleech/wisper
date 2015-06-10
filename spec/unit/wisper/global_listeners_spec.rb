describe Wisper::GlobalListeners do
  subject { described_class }

  let(:listener)  { double('listener') }
  let(:publisher) { publisher_class.new }

  describe '.subscribe' do
    it 'registers listener' do
      subject.subscribe(listener)
      expect(subject.registrations).not_to be_empty
    end

    it 'is threadsafe' do
      num_threads = 100
      (1..num_threads).to_a.map do
        Thread.new do
          subject.subscribe(listener)
          sleep(rand) # a little chaos
        end
      end.each(&:join)

      expect(subject.listeners.size).to eq num_threads
    end

    it 'returns self' do
      expect(subject.subscribe {}).to be_an_instance_of(subject)
    end
  end

  describe '.registrations' do
    context 'when no listeners registered' do
      it 'is empty' do
        expect(subject.registrations).to be_empty
      end
    end

    context 'when listeners registered' do
      before { subject.subscribe(listener) }

      it 'is not empty' do
        expect(subject.registrations).not_to be_empty
      end

      it 'returns registrations' do
        expect(subject.registrations).to include(instance_of(Wisper::ObjectRegistration))
      end
    end
  end

  describe '.listeners' do
    context 'when no listeners subscribed' do
      it 'is empty' do
        expect(subject.listeners).to be_empty
      end
    end

    context 'when listeners subscribed' do
      before { subject.subscribe(listener) }

      it 'returns global listeners' do
        expect(subject.listeners).to include listener
      end
    end

    it 'returns an immutable collection' do
      expect(subject.listeners).to be_frozen
      expect { subject.listeners << listener }.to raise_error(RuntimeError)
    end
  end

  describe '.clear' do
    before { subject.subscribe(listener) }

    it 'clears all global listeners' do
      subject.clear
      expect(subject.listeners).to be_empty
    end
  end
end
