require 'spec_helper'

describe Wisper do
  let(:listener)  { double('listener') }
  let(:publisher) { Object.new.extend(Wisper) }

  describe '.add_listener' do
    it 'subscribes listener to all published events' do
      listener.should_receive(:this_happened)
      listener.should_receive(:so_did_this)

      publisher.add_listener(listener)

      publisher.send(:broadcast, 'this_happened')
      publisher.send(:broadcast, 'so_did_this')
    end

    it 'subscribes listener to selected events' do
      listener.should_receive(:this_happened)
      listener.stub(:so_did_this)
      listener.should_not_receive(:so_did_this)

      listener.respond_to?(:so_did_this).should be_true

      publisher.add_listener(listener, :on => 'this_happened')

      publisher.send(:broadcast, 'this_happened')
      publisher.send(:broadcast, 'so_did_this')
    end

    it 'does not receive events it can not respond to' do
      listener.should_not_receive(:so_did_this)
      listener.stub(:respond_to?, false)

      listener.respond_to?(:so_did_this).should be_false

      publisher.add_listener(listener, :on => 'so_did_this')

      publisher.send(:broadcast, 'so_did_this')
    end
  end

  describe 'Block listeners' do
    it 'subscribes block to all events' do
      insider = double('insider')
      insider.should_receive(:it_happened)

      publisher.add_block_listener do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end

    it 'subscribes block to selected events' do
      insider = double('insider')
      insider.should_not_receive(:it_happened)

      publisher.add_block_listener(:on => 'this_thing_happened') do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end
  end
end
