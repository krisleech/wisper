describe Wisper::Publisher do
  let(:listener)  { double('listener') }
  let(:publisher) { publisher_class.new }

  describe '.subscribe' do
    it 'subscribes given listener to all published events' do
      expect(listener).to receive(:this_happened)
      expect(listener).to receive(:so_did_this)

      publisher.subscribe(listener)

      publisher.send(:broadcast, 'this_happened')
      publisher.send(:broadcast, 'so_did_this')
    end

    describe ':on argument' do
      it 'subscribes given listener to a single event' do
        expect(listener).to receive(:this_happened)
        allow(listener).to receive(:so_did_this)
        expect(listener).not_to receive(:so_did_this)

        expect(listener).to respond_to(:so_did_this)

        publisher.subscribe(listener, :on => 'this_happened')

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
      end

      it 'subscribes given listener to many events' do
        expect(listener).to receive(:this_happened)
        expect(listener).to receive(:and_this)
        allow(listener).to receive(:so_did_this)
        expect(listener).not_to receive(:so_did_this)

        expect(listener).to respond_to(:so_did_this)

        publisher.subscribe(listener, :on => ['this_happened', 'and_this'])

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
        publisher.send(:broadcast, 'and_this')
      end
    end

    describe ':with argument' do
      it 'sets method to call listener with on event' do
        expect(listener).to receive(:different_method).twice

        publisher.subscribe(listener, :with => :different_method)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'so_did_this')
      end
    end

    describe ':prefix argument' do
      it 'prefixes broadcast events with given symbol' do
        expect(listener).to receive(:after_it_happened)
        expect(listener).not_to receive(:it_happened)

        publisher.subscribe(listener, :prefix => :after)

        publisher.send(:broadcast, 'it_happened')
      end

      it 'prefixes broadcast events with "on" when given true' do
        expect(listener).to receive(:on_it_happened)
        expect(listener).not_to receive(:it_happened)

        publisher.subscribe(listener, :prefix => true)

        publisher.send(:broadcast, 'it_happened')
      end
    end

    # NOTE: these are not realistic use cases, since you would only ever use
    # `scope` when globally subscribing.
    describe ':scope argument' do
      let(:listener_1) { double('Listener') }
      let(:listener_2) { double('Listener') }

      it 'scopes listener to given class' do
        expect(listener_1).to receive(:it_happended)
        expect(listener_2).not_to receive(:it_happended)
        publisher.subscribe(listener_1, :scope => publisher.class)
        publisher.subscribe(listener_2, :scope => Class.new)
        publisher.send(:broadcast, 'it_happended')
      end

      it 'scopes listener to given class string' do
        expect(listener_1).to receive(:it_happended)
        expect(listener_2).not_to receive(:it_happended)
        publisher.subscribe(listener_1, :scope => publisher.class.to_s)
        publisher.subscribe(listener_2, :scope => Class.new.to_s)
        publisher.send(:broadcast, 'it_happended')
      end

      it 'includes all subclasses of given class' do
        publisher_super_klass = publisher_class
        publisher_sub_klass = Class.new(publisher_super_klass)

        listener = double('Listener')
        expect(listener).to receive(:it_happended).once

        publisher = publisher_sub_klass.new

        publisher.subscribe(listener, :scope => publisher_super_klass)
        publisher.send(:broadcast, 'it_happended')
      end
    end

    describe ':broadcaster argument'do
      let(:broadcaster) { double('broadcaster') }
      let(:listener)    { double('listener') }
      let(:event_name)  { 'it_happened' }

      before do
        Wisper.configuration.broadcasters.clear
        allow(listener).to    receive(event_name)
        allow(broadcaster).to receive(:broadcast)
      end

      after { Wisper.setup } # restore default configuration

      it 'given an object which responds_to broadcast it uses object' do
        publisher.subscribe(listener, broadcaster: broadcaster)
        expect(broadcaster).to receive('broadcast')
        publisher.send(:broadcast, event_name)
      end

      it 'given a key it uses a configured broadcaster' do
        Wisper.configure { |c| c.broadcaster(:foobar, broadcaster) }
        publisher.subscribe(listener, broadcaster: :foobar)
        expect(broadcaster).to receive('broadcast')
        publisher.send(:broadcast, event_name)
      end

      it 'given an unknown key it raises error' do
        expect { publisher.subscribe(listener, broadcaster: :foobar) }.to raise_error(KeyError, /broadcaster not found/)
      end

      it 'given nothing it uses the default broadcaster' do
        Wisper.configure { |c| c.broadcaster(:default, broadcaster) }
        publisher.subscribe(listener)
        expect(broadcaster).to receive('broadcast')
        publisher.send(:broadcast, event_name)
      end

      describe 'async alias' do
        it 'given an object which responds_to broadcast it uses object' do
          publisher.subscribe(listener, async: broadcaster)
          expect(broadcaster).to receive('broadcast')
          publisher.send(:broadcast, event_name)
        end

        it 'given true it uses configured async broadcaster' do
          Wisper.configure { |c| c.broadcaster(:async, broadcaster) }
          publisher.subscribe(listener, async: true)
          expect(broadcaster).to receive('broadcast')
          publisher.send(:broadcast, event_name)
        end

        it 'given false it uses configured default broadcaster' do
          Wisper.configure { |c| c.broadcaster(:default, broadcaster) }
          publisher.subscribe(listener, async: false)
          expect(broadcaster).to receive('broadcast')
          publisher.send(:broadcast, event_name)
        end
      end
    end

    it 'returns publisher so methods can be chained' do
      expect(publisher.subscribe(listener, :on => 'so_did_this')).to \
        eq publisher
    end

    it 'is aliased to .subscribe' do
      expect(publisher).to respond_to(:subscribe)
    end
  end

  describe '.on' do
    let(:insider) { double('insider') }

    it 'subscribes block to given event' do
      expect(insider).to receive(:yes).once

      publisher.on(:something_happened) do
        insider.yes
      end

      publisher.send(:broadcast, :something_happened)
      publisher.send(:broadcast, :and_so_did_this)
    end

    it 'subscribes block to given events' do
      expect(insider).to receive(:yes).twice

      publisher.on(:something_happened, :and_so_did_this) do
        insider.yes
      end

      publisher.send(:broadcast, :something_happened)
      publisher.send(:broadcast, :and_so_did_this)
    end

    it 'raise an error if no events given' do
      expect { publisher.on() {} }.to raise_error(ArgumentError)
    end

    it 'returns publisher so methods can be chained' do
      expect(publisher.on(:foo) {}).to eq publisher
    end
  end

  # @deprecated
  describe '.add_listener' do
    it 'is aliased to .subscribe' do
      expect(publisher).to receive(:subscribe)
      silence_warnings do
        publisher.add_listener(listener)
      end
    end
  end

  # @deprecated
  describe '.add_block_listener' do
    let(:insider) { double('insider') }

    it 'subscribes given block to all events' do
      expect(insider).to receive(:it_happened).twice

      silence_warnings do
        publisher.add_block_listener do
          insider.it_happened
        end
      end

      publisher.send(:broadcast, 'something_happened')
      publisher.send(:broadcast, 'and_so_did_this')
    end

    describe ':on argument' do
      it '.add_block_listener subscribes block to an event' do
        expect(insider).not_to receive(:it_happened).once

        silence_warnings do
          publisher.add_block_listener(:on => 'something_happened') do
            insider.it_happened
          end
        end

        publisher.send(:broadcast, 'something_happened')
        publisher.send(:broadcast, 'and_so_did_this')
      end

      it '.add_block_listener subscribes block to all listed events' do
        expect(insider).to receive(:it_happened).twice

        silence_warnings do
          publisher.add_block_listener(
            :on => ['something_happened', 'and_so_did_this']) do
            insider.it_happened
          end
        end

        publisher.send(:broadcast, 'something_happened')
        publisher.send(:broadcast, 'and_so_did_this')
        publisher.send(:broadcast, 'but_not_this')
      end
    end

    it 'returns publisher so methods can be chained' do
      silence_warnings do
        expect(publisher.add_block_listener(:on => 'this_thing_happened') do
        end).to eq publisher
      end
    end
  end

  # @deprecated
  describe '.respond_to (alternative block syntax)' do
    it 'delegates to .on' do
      expect(publisher).to receive(:on).with(:foobar)
      silence_warnings do
        publisher.respond_to(:foobar) {  }
      end
    end
  end

  describe '.broadcast' do
    it 'does not publish events which cannot be responded to' do
      expect(listener).not_to receive(:so_did_this)
      allow(listener).to receive(:respond_to?).and_return(false)

      publisher.subscribe(listener, :on => 'so_did_this')

      publisher.send(:broadcast, 'so_did_this')
    end

    describe ':event argument' do
      it 'is indifferent to string and symbol' do
        expect(listener).to receive(:this_happened).twice

        publisher.subscribe(listener)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, :this_happened)
      end

      it 'is indifferent to dasherized and underscored strings' do
        expect(listener).to receive(:this_happened).twice

        publisher.subscribe(listener)

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
       publisher.subscribe(listener)
       expect(publisher.listeners).to eq [listener]
       expect(publisher.listeners.size).to eq 1
    end
  end

  describe '#subscribe' do
    let(:publisher_klass_1) { publisher_class }
    let(:publisher_klass_2) { publisher_class }

    it 'subscribes listener to all instances of publisher' do
      publisher_klass_1.subscribe(listener)
      expect(listener).to receive(:it_happened).once
      publisher_klass_1.new.send(:broadcast, 'it_happened')
      publisher_klass_2.new.send(:broadcast, 'it_happened')
    end
  end

  describe '#add_listener' do # deprecated
    it 'is aliased to #subscribe' do
      expect(publisher).to receive(:subscribe)
      silence_warnings do
        publisher.add_listener(listener)
      end
    end
  end
end
