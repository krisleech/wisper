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

    it 'adding listeners can be chained' do
      publisher.add_listener(listener, :on => 'so_did_this').should == publisher
    end
  end

  describe 'Block listeners' do
    it '.add_block_listener subscribes block to all events' do
      insider = double('insider')
      insider.should_receive(:it_happened)

      publisher.add_block_listener do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end

    it '.add_block_listener subscribes block to selected events' do
      insider = double('insider')
      insider.should_not_receive(:it_happened)

      publisher.add_block_listener(:on => 'this_thing_happened') do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end

    it '.add_block_listener can be chained' do
      publisher.add_block_listener(:on => 'this_thing_happened') do
      end.should == publisher
    end

    it '.respond_to subscribes block to all events' do
      insider = double('insider')
      insider.should_receive(:it_happened)

      publisher.respond_to(:something_happened) do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end

    it '.on subscribes block to all events' do
      insider = double('insider')
      insider.should_receive(:it_happened)

      publisher.on(:something_happened) do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end
  end

  describe '.broadcast' do
    describe 'event argument' do
      it 'is indifferent to string and symbol' do
        listener.should_receive(:this_happened).twice

        publisher.add_listener(listener)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, :this_happened)
      end

      it 'is indifferent to dasherized and underscored strings' do
        listener.should_receive(:this_happened).twice

        publisher.add_listener(listener)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'this-happened')
      end
    end
  end
end
