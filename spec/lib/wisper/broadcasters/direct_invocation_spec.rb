require 'spec_helper'

describe Wisper::Broadcasters::DirectInvocation do
  describe '#broadcast_event' do
    let(:listener){ double(:listener) }
    let(:registration){ double(:registration, listener: listener) }
    let(:broadcaster){ Wisper::Broadcasters::DirectInvocation.new(registration) }

    it 'sends event to listener' do
      expect(registration).to receive(:method_name).with(:event).and_return('event')
      expect(listener).to receive(:event).with('arg1', 'arg2')
      broadcaster.broadcast_event(:event, double, ['arg1', 'arg2'])
    end
  end

  describe '#should_broadcast?' do
    let(:listener) do
      Class.new do
        include Wisper::Publisher
        def event
        end
      end.new
    end

    let(:options){ { on: event } }
    let(:event){ :event }
    let(:publisher){ publisher_class.new }
    let(:registration){ double(:registration, listener: listener, method_name: event) }
    let(:broadcaster){ Wisper::Broadcasters::DirectInvocation.new(registration, options) }

    it 'will return true if the same event was sended' do
      expect(broadcaster.should_broadcast?('event', publisher)).to be_truthy
    end

    it 'will return false if defferent event was sended' do
      expect(broadcaster.should_broadcast?('another_event', publisher)).to be_falsy
    end

    context 'when option :on is nil' do
      let(:options){ {} }

      it 'will return true if the same event was sended' do
        expect(broadcaster.should_broadcast?('event', publisher)).to be_truthy
      end
    end

    context 'when listener does not respond to event' do
      let(:event){ :another_event }

      it 'will return false' do
        expect(broadcaster.should_broadcast?('another_event', publisher)).to be_falsy
      end
    end

    context 'when publisher fits to scope' do
      let(:options){ { scope: publisher.class } }

      it 'will return false' do
        expect(broadcaster.should_broadcast?('event', publisher)).to be_truthy
      end
    end

    context 'when publisher does not fit to scope' do
      let(:options){ { scope: String } }

      it 'will return false' do
        expect(broadcaster.should_broadcast?('event', publisher)).to be_falsy
      end
    end
  end
end
