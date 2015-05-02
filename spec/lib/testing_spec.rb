if ENV['INCLUDE_WISPER_TESTING']
  describe Wisper::Testing do
    let(:our_publisher_class) { publisher_class }
    let(:publisher) { our_publisher_class.new }
    let(:listener) { double('listener', event_name: true) }

    describe 'Wisper::Publisher.wisper_subscribed_locally?' do
      subject { publisher.wisper_subscribed_locally?(listener) }

      context 'when the listener is not registered' do
        it { is_expected.to be_falsey }
      end
      context 'when the listener is registered' do
        before do
          publisher.subscribe(listener)
        end
        it { is_expected.to be_truthy }
      end
    end

    describe 'Wisper.subscribed?' do
      subject { Wisper.subscribed?(listener) }

      context 'when the listener is not registered' do
        it { is_expected.to be_falsey }
      end
      context 'when the listener is registered' do
        before do
          Wisper.subscribe(listener)
        end
        it { is_expected.to be_truthy }
      end
    end

    describe 'Wisper.subscribed_to_publisher?' do
      subject { Wisper.subscribed_to_publisher?(listener, our_publisher_class) }

      context 'when the listener is not registered' do
        it { is_expected.to be_falsey }
      end
      context 'when the listener is registered' do
        before do
          our_publisher_class.subscribe(listener)
        end
        it { is_expected.to be_truthy }
      end
    end

    describe 'Wisper.with_testing_event_recorder' do
      let(:event_recorder) { double('event_recorder', event_name: true) }
      before do
        publisher.subscribe(listener)
      end
      subject {
        Wisper::Publisher.with_testing_event_recorder(event_recorder) do
          publisher.send(:broadcast, 'event_name', :arg1, :arg2)
        end
      }
      it 'records the event' do
        expect(event_recorder).to receive(:event_name).with(:arg1, :arg2)
        subject
      end
      context 'with Wisper::Testing.enabled (the default)' do
        it 'publishes the event' do
          expect(listener).to receive(:event_name).with(:arg1, :arg2)
          subject
        end
      end
      context 'with Wisper::Testing.disabled' do
        before do
          Wisper::Testing.disable!
        end
        after do
          Wisper::Testing.enable!
        end
        it 'does not publish the event' do
          expect(listener).not_to receive(:event_name).with(:arg1, :arg2)
          subject
        end
      end
    end
  end
end
