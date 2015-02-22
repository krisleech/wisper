describe Wisper::Publisher do
  let(:listener)  { double('listener') }
  let(:publisher) { publisher_class.new }

  let(:first_event)  { 'first_event' }
  let(:second_event) { 'second_event' }
  let(:third_event)  { 'third_event' }

  before do
    allow(listener).to receive(first_event)
    allow(listener).to receive(second_event)
    allow(listener).to receive(third_event)
  end

  describe '.subscribe' do
    it 'subscribes given listener to all published events' do
      expect(listener).to receive(first_event)
      expect(listener).to receive(second_event)

      publisher.subscribe(listener)

      publisher.send(:broadcast, first_event)
      publisher.send(:broadcast, second_event)
    end

    describe ':on argument' do
      describe 'given a string' do
        it 'subscribes listener to an event' do
          expect(listener).to receive(first_event)
          expect(listener).not_to receive(second_event)

          publisher.subscribe(listener, on: first_event.to_s)

          publisher.send(:broadcast, first_event)
          publisher.send(:broadcast, second_event)
        end
      end

      describe 'given a symbol' do
        it 'subscribes listener to an event' do
          expect(listener).to receive(first_event)
          expect(listener).not_to receive(second_event)

          publisher.subscribe(listener, on: first_event.to_sym)

          publisher.send(:broadcast, first_event)
          publisher.send(:broadcast, second_event)
        end
      end

      describe 'given an array' do
        it 'subscribes listener to events' do
          expect(listener).to receive(first_event)
          expect(listener).to receive(second_event)
          expect(listener).not_to receive(third_event)

          publisher.subscribe(listener, on: [first_event, second_event])

          publisher.send(:broadcast, first_event)
          publisher.send(:broadcast, second_event)
          publisher.send(:broadcast, third_event)
        end
      end

      describe 'given a regex' do
        it 'subscribes listener to matching events' do
          expect(listener).to receive(:something_a_happened)
          expect(listener).not_to receive(:so_did_this)

          publisher.subscribe(listener, on: /something_._happened/)

          publisher.send(:broadcast, 'something_a_happened')
          publisher.send(:broadcast, 'so_did_this')
        end
      end

      describe 'given an unsupported argument' do
        it 'raises an error' do
          publisher.subscribe(listener, on: Object.new)
          expect { publisher.send(:broadcast, first_event) }.to raise_error(ArgumentError)
        end
      end
    end

    describe ':with argument' do
      it 'sets method to invoke on listener with on event' do
        expect(listener).to receive(:different_event).twice

        publisher.subscribe(listener, with: :different_event)

        publisher.send(:broadcast, first_event)
        publisher.send(:broadcast, second_event)
      end
    end

    describe ':prefix argument' do
      it 'prefixes broadcast events with given symbol' do
        expect(listener).to receive("after_#{first_event}")
        expect(listener).not_to receive(first_event)

        publisher.subscribe(listener, prefix: :after)

        publisher.send(:broadcast, first_event)
      end

      it 'prefixes broadcast events with "on" when given true' do
        expect(listener).to receive("on_#{first_event}")
        expect(listener).not_to receive(first_event)

        publisher.subscribe(listener, prefix: true)

        publisher.send(:broadcast, first_event)
      end
    end

    describe ':scope argument' do
      let(:another_listener) { double('another_listener') }

      it 'scopes listener to given class' do
        expect(listener).to receive(first_event)
        expect(another_listener).not_to receive(first_event)
        publisher.subscribe(listener, scope: publisher.class)
        publisher.subscribe(another_listener, scope: Class.new)
        publisher.send(:broadcast, first_event)
      end

      it 'scopes listener to given class string' do
        expect(listener).to receive(first_event)
        expect(another_listener).not_to receive(first_event)
        publisher.subscribe(listener, scope: publisher.class.to_s)
        publisher.subscribe(another_listener, scope: Class.new.to_s)
        publisher.send(:broadcast, first_event)
      end

      it 'includes all subclasses of given class' do
        publisher_super_klass = publisher_class
        publisher_sub_klass = Class.new(publisher_super_klass)

        expect(listener).to receive(first_event).once

        publisher = publisher_sub_klass.new

        publisher.subscribe(listener, scope: publisher_super_klass)
        publisher.send(:broadcast, first_event)
      end
    end

    describe ':broadcaster argument'do
      let(:broadcaster) { double('broadcaster') }

      before do
        Wisper.configuration.broadcasters.clear
        allow(listener).to    receive(first_event)
        allow(broadcaster).to receive(:broadcast)
      end

      after { Wisper.setup } # restore default configuration

      it 'given an object which responds_to broadcast it uses object' do
        publisher.subscribe(listener, broadcaster: broadcaster)
        expect(broadcaster).to receive('broadcast')
        publisher.send(:broadcast, first_event)
      end

      it 'given a key it uses a configured broadcaster' do
        Wisper.configure { |c| c.broadcaster(:foobar, broadcaster) }
        publisher.subscribe(listener, broadcaster: :foobar)
        expect(broadcaster).to receive('broadcast')
        publisher.send(:broadcast, first_event)
      end

      it 'given an unknown key it raises error' do
        expect { publisher.subscribe(listener, broadcaster: :foobar) }.to raise_error(KeyError, /broadcaster not found/)
      end

      it 'given nothing it uses the default broadcaster' do
        Wisper.configure { |c| c.broadcaster(:default, broadcaster) }
        publisher.subscribe(listener)
        expect(broadcaster).to receive('broadcast')
        publisher.send(:broadcast, first_event)
      end

      describe 'async alias' do
        it 'given an object which responds_to broadcast it uses object' do
          publisher.subscribe(listener, async: broadcaster)
          expect(broadcaster).to receive('broadcast')
          publisher.send(:broadcast, first_event)
        end

        it 'given true it uses configured async broadcaster' do
          Wisper.configure { |c| c.broadcaster(:async, broadcaster) }
          publisher.subscribe(listener, async: true)
          expect(broadcaster).to receive('broadcast')
          publisher.send(:broadcast, first_event)
        end

        it 'given false it uses configured default broadcaster' do
          Wisper.configure { |c| c.broadcaster(:default, broadcaster) }
          publisher.subscribe(listener, async: false)
          expect(broadcaster).to receive('broadcast')
          publisher.send(:broadcast, first_event)
        end
      end
    end

    it 'returns publisher so methods can be chained' do
      expect(publisher.subscribe(listener, on: first_event)).to eq publisher
    end

    it 'is aliased to .subscribe' do
      expect(publisher).to respond_to(:subscribe)
    end
  end

  describe '.on' do
    it 'returns publisher so methods can be chained' do
      expect(publisher.on(first_event) {}).to eq publisher
    end

    it 'raise an error if no events given' do
      expect { publisher.on() {} }.to raise_error(ArgumentError)
    end

    it 'returns publisher so methods can be chained' do
      expect(publisher.on(first_event) {}).to eq publisher
    end
  end

  describe '.broadcast' do

    it 'does not publish events which cannot be responded to' do
      expect(listener).not_to receive(:so_did_this)
      allow(listener).to receive(:respond_to?).and_return(false)

      publisher.subscribe(listener, on: 'so_did_this')

      publisher.send(:broadcast, 'so_did_this')
    end

    describe ':event argument' do
      it 'is indifferent to string and symbol' do
        expect(listener).to receive(first_event).twice

        publisher.subscribe(listener)

        publisher.send(:broadcast, first_event.to_s)
        publisher.send(:broadcast, first_event.to_sym)
      end

      it 'is indifferent to dasherized and underscored strings' do
        expect(listener).to receive(:this_happened).twice

        publisher.subscribe(listener)

        publisher.send(:broadcast, 'this_happened')
        publisher.send(:broadcast, 'this-happened')
      end
    end

    it 'returns publisher' do
      expect(publisher.send(:broadcast, first_event)).to eq publisher
    end

    it 'is not public' do
      expect(publisher).not_to respond_to(:broadcast)
    end

    it 'is alised as .publish' do
      expect(publisher.method(:broadcast)).to eq publisher.method(:publish)
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
      expect(listener).to receive(first_event).once
      publisher_klass_1.new.send(:broadcast, first_event)
      publisher_klass_2.new.send(:broadcast, first_event)
    end
  end
end
