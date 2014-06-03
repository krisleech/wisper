require 'spec_helper'

describe Wisper::Publisher do
  let(:listener)  { double('listener') }
  let(:publisher) { publisher_class.new }

  describe '.add_listener' do
    it 'subscribes given listener to all published events' do
      expect(listener).to receive(:this_happened)
      expect(listener).to receive(:so_did_this)

      publisher.add_listener(listener)

      publisher.send(:broadcast, 'this_happened')
      publisher.send(:broadcast, 'so_did_this')
    end

    describe ':on argument' do
      it 'subscribes given listener to a single event' do
        expect(listener).to receive(:this_happened)
        allow(listener).to receive(:so_did_this)
        expect(listener).not_to receive(:so_did_this)

        expect(listener).to respond_to(:so_did_this)

        publisher.add_listener(listener, :on => 'this_happened')

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
      end

      it 'subscribes given listener to many events' do
        expect(listener).to receive(:this_happened)
        expect(listener).to receive(:and_this)
        allow(listener).to receive(:so_did_this)
        expect(listener).not_to receive(:so_did_this)

        expect(listener).to respond_to(:so_did_this)

        publisher.add_listener(listener, :on => ['this_happened', 'and_this'])

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
        publisher.send(:broadcast, 'and_this')
      end
    end

    describe ':with argument' do
      it 'sets method to call listener with on event' do
        expect(listener).to receive(:different_method).twice

        publisher.add_listener(listener, :with => :different_method)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
      end
    end

    describe ':prefix argument' do
      it 'prefixes broadcast events with given symbol' do
        expect(listener).to receive(:after_it_happened)
        expect(listener).not_to receive(:it_happened)

        publisher.add_listener(listener, :prefix => :after)

        publisher.send(:broadcast, 'it_happened')
      end

      it 'prefixes broadcast events with "on" when given true' do
        expect(listener).to receive(:on_it_happened)
        expect(listener).not_to receive(:it_happened)

        publisher.add_listener(listener, :prefix => true)

        publisher.send(:broadcast, 'it_happened')
      end
    end

    describe ':class_prefix argument' do
      it 'prefixes broadcast evens with publisher class name' do
        publisher = Wisper::ExamplePublisher.new
        expect(listener).to receive(:wisper_example_publisher_it_happened)
        publisher.add_listener(listener, :class_prefix => true)
        publisher.send(:broadcast, 'it_happened')
      end

      it 'supports custom class prefixes' do
        publisher = Wisper::CustomClassPrefixPublisher.new
        expect(listener).to receive(:i_am_custom_it_happened)
        publisher.add_listener(listener, :class_prefix => true)
        publisher.send(:broadcast, 'it_happened')
      end
    end

    # NOTE: these are not realistic use cases, since you would only ever use
    # `scope` when globally subscribing.
    describe ':scope argument' do
      let(:listener_1) { double('Listener') }
      let(:listener_2) { double('Listener') }

      before do
      end

      it 'scopes listener to given class' do
        expect(listener_1).to receive(:it_happended)
        expect(listener_2).not_to receive(:it_happended)
        publisher.add_listener(listener_1, :scope => publisher.class)
        publisher.add_listener(listener_2, :scope => Class.new)
        publisher.send(:broadcast, 'it_happended')
      end

      it 'scopes listener to given class string' do
        expect(listener_1).to receive(:it_happended)
        expect(listener_2).not_to receive(:it_happended)
        publisher.add_listener(listener_1, :scope => publisher.class.to_s)
        publisher.add_listener(listener_2, :scope => Class.new.to_s)
        publisher.send(:broadcast, 'it_happended')
      end

      it 'includes all subclasses of given class' do
        publisher_super_klass = publisher_class
        publisher_sub_klass = Class.new(publisher_super_klass)

        listener = double('Listener')
        expect(listener).to receive(:it_happended).once

        publisher = publisher_sub_klass.new

        publisher.add_listener(listener, :scope => publisher_super_klass)
        publisher.send(:broadcast, 'it_happended')
      end
    end

    it 'returns publisher so methods can be chained' do
      expect(publisher.add_listener(listener, :on => 'so_did_this')).to \
        eq publisher
    end

    it 'is aliased to .subscribe' do
      expect(publisher).to respond_to(:subscribe)
    end
  end

  describe '.add_block_listener' do
    let(:insider) { double('insider') }

    it 'subscribes given block to all events' do
      expect(insider).to receive(:it_happened).twice

      publisher.add_block_listener do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
      publisher.send(:broadcast, 'and_so_did_this')
    end

    describe ':on argument' do
      it '.add_block_listener subscribes block to an event' do
        expect(insider).not_to receive(:it_happened).once

        publisher.add_block_listener(:on => 'something_happened') do
          insider.it_happened
        end

        publisher.send(:broadcast, 'something_happened')
        publisher.send(:broadcast, 'and_so_did_this')
      end

      it '.add_block_listener subscribes block to all listed events' do
        expect(insider).to receive(:it_happened).twice

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
      expect(publisher.add_block_listener(:on => 'this_thing_happened') do
      end).to eq publisher
    end
  end

  describe '.on (alternative block syntax)' do
    let(:insider) { double('insider') }

    it 'subscribes given block to an event' do
      expect(insider).to receive(:it_happened)

      publisher.on(:something_happened) do
        insider.it_happened
      end

      publisher.send(:broadcast, 'something_happened')
    end

    it 'subscribes given block to multiple events' do
      expect(insider).to receive(:it_happened).twice

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
      expect(listener).not_to receive(:so_did_this)
      allow(listener).to receive(:respond_to?).and_return(false)

      publisher.add_listener(listener, :on => 'so_did_this')

      publisher.send(:broadcast, 'so_did_this')
    end

    describe ':event argument' do
      it 'is indifferent to string and symbol' do
        expect(listener).to receive(:this_happened).twice

        publisher.add_listener(listener)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, :this_happened)
      end

      it 'is indifferent to dasherized and underscored strings' do
        expect(listener).to receive(:this_happened).twice

        publisher.add_listener(listener)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'this-happened')
      end
    end
  end

  describe '.listeners' do
    it 'returns an immutable collection' do
      expect(publisher.listeners).to be_frozen
      expect { publisher.listeners << listener }.to raise_error(RuntimeError)
    end

    it 'returns local listeners' do
       publisher.add_listener(listener)
       expect(publisher.listeners).to eq [listener]
       expect(publisher.listeners.size).to eq 1
    end
  end

  describe '#add_listener' do
    let(:publisher_klass_1) { publisher_class }
    let(:publisher_klass_2) { publisher_class }

    it 'subscribes listeners to all instances of publisher' do
      publisher_klass_1.add_listener(listener)
      expect(listener).to receive(:it_happened).once
      publisher_klass_1.new.send(:broadcast, 'it_happened')
      publisher_klass_2.new.send(:broadcast, 'it_happened')
    end

    it 'is aliased to #subscribe' do
      expect(publisher_klass_1).to respond_to(:subscribe)
    end
  end
end
