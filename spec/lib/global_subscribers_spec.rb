require 'spec_helper'

describe Wisper do
  let(:global_listener)  { double('listener') }
  let(:local_listener)   { double('listener') }
  let(:publisher) { Object.new.extend(Wisper) }

  it '.add_listener' do
    Wisper::GlobalListeners.add_listener(global_listener)
    global_listener.should_receive(:it_happened)
    publisher.send(:broadcast, :it_happened)
  end

  it 'mix and match local and global listeners' do
    Wisper::GlobalListeners.add_listener(global_listener)
    global_listener.should_receive(:it_happened)
    local_listener.should_receive(:it_happened)
    publisher.add_listener(local_listener)
    publisher.send(:broadcast, :it_happened)
  end
end

