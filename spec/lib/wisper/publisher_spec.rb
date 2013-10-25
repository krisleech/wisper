require 'spec_helper'

describe Wisper::Publisher do
  let(:listener)  { double('listener') }
  let(:publisher) { publisher_class.new }

  describe '.add_listener' do
    it 'subscribes given listener to all published events' do
      listener.should_receive(:this_happened)
      listener.should_receive(:so_did_this)

      publisher.add_listener(listener)

      publisher.send(:broadcast, 'this_happened')
      publisher.send(:broadcast, 'so_did_this')
    end

    describe ':on argument' do
      it 'subscribes given listener to a single event' do
        listener.should_receive(:this_happened)
        listener.stub(:so_did_this)
        listener.should_not_receive(:so_did_this)

        listener.respond_to?(:so_did_this).should be_true

        publisher.add_listener(listener, :on => 'this_happened')

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
      end

      it 'subscribes given listener to many events' do
        listener.should_receive(:this_happened)
        listener.should_receive(:and_this)
        listener.stub(:so_did_this)
        listener.should_not_receive(:so_did_this)

        listener.respond_to?(:so_did_this).should be_true

        publisher.add_listener(listener, :on => ['this_happened', 'and_this'])

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
        publisher.send(:broadcast, 'and_this')
      end
    end

    describe ':with argument' do
      it 'sets method to call listener with on event' do
        listener.should_receive(:different_method).twice

        publisher.add_listener(listener, :with => :different_method)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
      end
    end

    it 'returns publisher so methods can be chained' do
      publisher.add_listener(listener, :on => 'so_did_this').should == publisher
    end

    it 'is aliased to .subscribe' do
      publisher.respond_to?(:subscribe).should be_true
    end
  end

  describe '.add_block_listener' do
    let(:insider) { double('insider') }

    it 'subscribes given block to all events' do
      insider.should_receive(:it_happened).twice

      publisher.add_block_listener do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
      publisher.send(:broadcast, 'and_so_did_this')
    end

    describe ':on argument' do
      it '.add_block_listener subscribes block to an event' do
        insider.should_not_receive(:it_happened).once

        publisher.add_block_listener(:on => 'something_happened') do
          insider.it_happened
        end

        publisher.send(:broadcast, 'something_happened')
        publisher.send(:broadcast, 'and_so_did_this')
      end

      it '.add_block_listener subscribes block to all listed events' do
        insider.should_receive(:it_happened).twice

        publisher.add_block_listener(
          :on => ['something_happened', 'and_so_did_this']) do
          insider.it_happened
        end

        publisher.send(:broadcast, 'something_happened')
        publisher.send(:broadcast, 'and_so_did_this')
        publisher.send(:broadcast, 'but_not_this')
      end
    end

    it 'returns publisher so methods can be chained' do
      publisher.add_block_listener(:on => 'this_thing_happened') do
      end.should == publisher
    end
  end

  describe '.on (alternative block syntax)' do
    let(:insider) { double('insider') }

    it 'subscribes given block to an event' do
      insider.should_receive(:it_happened)

      publisher.on(:something_happened) do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end

    it 'subscribes given block to multiple events' do
      insider.should_receive(:it_happened).twice

      publisher.on(:something_happened, :and_so_did_this) do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
      publisher.send(:broadcast, 'and_so_did_this')
      publisher.send(:broadcast, 'but_not_this')
    end
  end

  describe '.broadcast' do
    it 'does not publish events which cannot be responded to' do
      listener.should_not_receive(:so_did_this)
      listener.stub(:respond_to? => false)

      publisher.add_listener(listener, :on => 'so_did_this')

      publisher.send(:broadcast, 'so_did_this')
    end

    it 'moves on to the next subscribed listener if a listener raises an exception' do
      second_listener = double('second_listener')
      listener.should_receive(:so_did_this).and_raise('Exception')
      second_listener.should_receive(:so_did_this)

      publisher.add_listener(listener)
      publisher.add_listener(second_listener)

      publisher.send(:broadcast, 'so_did_this')
    end

    describe ':event argument' do
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

  describe '.listeners' do
    it 'returns an immutable collection' do
      publisher.listeners.frozen?.should be_true
      expect { publisher.listeners << listener }.to raise_error(RuntimeError)
    end

    it 'returns local listeners' do
       publisher.add_listener(listener)
       publisher.listeners.should == [listener]
       publisher.listeners.size.should == 1
    end
  end
end
