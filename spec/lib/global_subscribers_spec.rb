require 'spec_helper'

describe Wisper::GlobalListeners do
  let(:global_listener)  { double('listener') }
  let(:local_listener)   { double('listener') }
  let(:publisher)        { Object.new.extend(Wisper) }

  describe '.add_listener' do
    it 'adds given listener to every publisher' do
      Wisper::GlobalListeners.add_listener(global_listener)
      global_listener.should_receive(:it_happened)
      publisher.send(:broadcast, :it_happened)
    end

    it 'works along side local listeners' do
      # global listener
      Wisper::GlobalListeners.add_listener(global_listener)

      # local listener
      publisher.add_listener(local_listener)

      global_listener.should_receive(:it_happened)
      local_listener.should_receive(:it_happened)

      publisher.send(:broadcast, :it_happened)
    end
  end
end
