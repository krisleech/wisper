require 'spec_helper'

describe Wisper do

  it 'includes Wisper::Publisher for backwards compatibility' do
    silence_warnings do
      publisher_class = Class.new { include Wisper }
      expect(publisher_class.ancestors).to include Wisper::Publisher
    end
  end

  it '.with_listeners subscribes listeners to all broadcast events for the duration of block' do
    publisher = publisher_class.new
    listener = double('listener')

    expect(listener).to receive(:im_here)
    expect(listener).not_to receive(:not_here)

    Wisper.with_listeners(listener) do
      publisher.send(:broadcast, 'im_here')
    end

    publisher.send(:broadcast, 'not_here')
  end

  it '.add_listener adds a global listener' do
    listener = double('listener')
    Wisper.add_listener(listener)
    expect(Wisper::GlobalListeners.listeners).to eq [listener]
  end
end
