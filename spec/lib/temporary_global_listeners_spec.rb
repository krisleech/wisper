require 'spec_helper'

describe Wisper::TemporaryListeners do
  let(:listener_1) { double('listener', :to_a => nil) } # [1]
  let(:listener_2) { double('listener', :to_a => nil) }
  let(:publisher)  { Object.class_eval { include Wisper::Publisher } }

  describe '.with' do
    it 'globally subscribes listener for duration of given block' do

      expect(listener_1).to receive(:success)
      expect(listener_1).to_not receive(:failure)

      Wisper::TemporaryListeners.with(listener_1) do
        publisher.instance_eval { broadcast(:success) }
      end

      publisher.instance_eval { broadcast(:failure) }
    end

    it 'globally subscribes listeners for duration of given block' do

      expect(listener_1).to receive(:success)
      expect(listener_1).to_not receive(:failure)

      expect(listener_2).to receive(:success)
      expect(listener_2).to_not receive(:failure)

      Wisper::TemporaryListeners.with(listener_1, listener_2) do
        publisher.instance_eval { broadcast(:success) }
      end

      publisher.instance_eval { broadcast(:failure) }
    end

    it 'ensures registrations are thread local' do
      num_threads = 20
      (1..num_threads).to_a.map do
        Thread.new do
          Wisper::TemporaryListeners.registrations << Object.new
          expect(Wisper::TemporaryListeners.registrations.size).to eql 1
        end
      end.each(&:join)

      expect(Wisper::TemporaryListeners.registrations.size).to eql 0
    end

    it 'ensures registrations are cleared after exception raised in block' do
      begin
        Wisper::TemporaryListeners.with(listener_1) do
          raise StandardError
        end
      rescue StandardError
      end

      expect(Wisper::TemporaryListeners.registrations.size).to eql 0
    end
  end
end

# [1] stubbing `to_a` prevents `Double "listener" received unexpected message
# :to_a with (no args)` on MRI 1.9.2 when a double is passed to `Array()`.
