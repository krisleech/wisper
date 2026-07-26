# frozen_string_literal: true

describe Wisper::TemporaryListeners do
  let(:listener_1) { double('listener', :to_a => nil) } # [1]
  let(:listener_2) { double('listener', :to_a => nil) }

  let(:publisher)  { publisher_class.new }

  describe '.subscribe' do
    it 'globally subscribes listener for duration of given block' do
      expect(listener_1).to receive(:success)
      expect(listener_1).not_to receive(:failure)

      described_class.subscribe(listener_1) do
        publisher.instance_eval { broadcast(:success) }
      end

      publisher.instance_eval { broadcast(:failure) }
    end

    it 'globally subscribes listeners for duration of given block' do
      expect(listener_1).to receive(:success)
      expect(listener_1).not_to receive(:failure)

      expect(listener_2).to receive(:success)
      expect(listener_2).not_to receive(:failure)

      described_class.subscribe(listener_1, listener_2) do
        publisher.instance_eval { broadcast(:success) }
      end

      publisher.instance_eval { broadcast(:failure) }
    end

    it 'globally subscribes listeners for duration of nested block' do
      expect(listener_1).to receive(:success)
      expect(listener_1).to receive(:failure)

      expect(listener_2).to receive(:success)
      expect(listener_2).not_to receive(:failure)

      described_class.subscribe(listener_1) do
        described_class.subscribe(listener_2) do
          publisher.instance_eval { broadcast(:success) }
        end
        publisher.instance_eval { broadcast(:failure) }
      end
    end

    it 'clears registrations for the block which exits' do
      # listener_1 is subscribed twice hence it's supposed to get the message twice
      expect(listener_1).to receive(:success).twice
      expect(listener_1).to receive(:failure)
      expect(listener_1).not_to receive(:ignored)

      expect(listener_2).to receive(:success)
      expect(listener_2).not_to receive(:failure)
      expect(listener_2).not_to receive(:ignored)

      described_class.subscribe(listener_1) do
        described_class.subscribe(listener_1, listener_2) do
          publisher.instance_eval { broadcast(:success) }
        end
        publisher.instance_eval { broadcast(:failure) }
      end
      publisher.instance_eval { broadcast(:ignored) }
    end

    it 'is thread safe' do
      num_threads = 20
      (1..num_threads).to_a.map do
        Thread.new do
          described_class.registrations << Object.new
          expect(described_class.registrations.size).to eq 1
        end
      end.each(&:join)

      expect(described_class.registrations).to be_empty
    end

    it 'clears registrations when an exception occurs' do
      expect do
        described_class.subscribe(listener_1) { raise 'boom' }
      end.to raise_error('boom')

      expect(described_class.registrations).to be_empty
    end

    it 'returns self' do
      expect(described_class.subscribe {}).to be_an_instance_of(described_class)
    end
  end
end

# [1] stubbing `to_a` prevents `Double "listener" received unexpected message
# :to_a with (no args)` on MRI 1.9.2 when a double is passed to `Array()`.
