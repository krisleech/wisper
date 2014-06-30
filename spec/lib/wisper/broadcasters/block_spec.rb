require 'spec_helper'

describe Wisper::Broadcasters::Block do
  describe '#broadcast_event' do
    let(:listener){ double(:object) }
    let(:registration){ double(:registration, listener: listener) }
    let(:broadcaster){ Wisper::Broadcasters::Block.new(registration) }

    it 'sends event to listener' do
      expect(listener).to receive(:call).with('arg1', 'arg2')
      broadcaster.broadcast_event(:event, double, ['arg1', 'arg2'])
    end
  end

  describe '#should_broadcast?' do
    let(:object){ double(:object) }
    let(:registration){ double(:registration) }
    let(:broadcaster){ Wisper::Broadcasters::Block.new(registration, on: :event) }

    it 'will return true if the same event was sended' do
      expect(broadcaster.should_broadcast?('event', double)).to be_truthy
    end

    it 'it will return false if defferent event was sended' do
      expect(broadcaster.should_broadcast?('another_event', double)).to be_falsy
    end
  end
end
