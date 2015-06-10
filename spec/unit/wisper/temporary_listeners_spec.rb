RSpec.describe Wisper::TemporaryListeners do
  subject { described_class }

  let(:listener)  { double('listener') }
  let(:publisher) { publisher_class.new }

  describe '.subscribe' do
    it 'registers listener' do
      subject.subscribe(listener) do
        expect(subject.registrations).not_to be_empty
      end
    end

    it 'is thread safe' do
      num_threads = 20
      (1..num_threads).to_a.map do
        Thread.new do
          subject.registrations << listener
          expect(subject.registrations.size).to eq 1
        end
      end.each(&:join)

      expect(subject.registrations).to be_empty
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
      it 'is not empty' do
        subject.subscribe(listener) do
          expect(subject.registrations).not_to be_empty
        end
      end

      it 'returns registrations' do
        subject.subscribe(listener) do
          expect(subject.registrations).to include(instance_of(Wisper::ObjectRegistration))
        end
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
      it 'returns temporary listeners' do
        subject.subscribe(listener) do
          expect(subject.listeners).to include listener
        end
      end
    end

    it 'returns an immutable collection' do
      expect(subject.listeners).to be_frozen
      expect { subject.listeners << listener }.to raise_error(RuntimeError)
    end
  end
end
