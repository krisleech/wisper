require 'spec_helper'

describe Wisper::GlobalListeners do
  let(:global_listener)  { double('listener') }
  let(:local_listener)   { double('listener') }
  let(:publisher)        { Object.new.extend(Wisper::Publisher) }

  after(:each) { Wisper::GlobalListeners.clear }

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

    it 'is threadsafe' do
      num_threads = 100
      (1..num_threads).to_a.map do
        Thread.new do
          Wisper::GlobalListeners.add_listener(Object.new)
          sleep(rand) # a little chaos
        end
      end.each(&:join)

      Wisper::GlobalListeners.listeners.size.should == num_threads
    end
  end

  describe '.listeners' do
    it 'returns collection of global listeners' do
      Wisper::GlobalListeners.add_listener(global_listener)
      Wisper::GlobalListeners.listeners.should == [global_listener]
    end

    it 'returns an immutable collection' do
      Wisper::GlobalListeners.listeners.frozen?.should be_true
      expect { Wisper::GlobalListeners.listeners << global_listener }.to raise_error(RuntimeError, /can't modify/)
    end
  end

  it '.clear clears all global listeners' do
    Wisper::GlobalListeners.add_listener(global_listener)
    Wisper::GlobalListeners.clear
    Wisper::GlobalListeners.listeners.should be_empty
  end
end
