describe Wisper::GlobalListeners do
  let(:global_listener)  { double('listener') }
  let(:local_listener)   { double('listener') }
  let(:publisher)        { publisher_class.new }

  describe '.subscribe' do
    it 'adds given listener to every publisher' do
      Wisper::GlobalListeners.subscribe(global_listener)
      expect(global_listener).to receive(:it_happened)
      publisher.send(:broadcast, :it_happened)
    end

    it 'works with options' do
      Wisper::GlobalListeners.subscribe(global_listener, :on => :it_happened,
                                                   :with => :woot)
      expect(global_listener).to receive(:woot).once
      expect(global_listener).not_to receive(:it_happened_again)
      publisher.send(:broadcast, :it_happened)
      publisher.send(:broadcast, :it_happened_again)
    end

    it 'works along side local listeners' do
      # global listener
      Wisper::GlobalListeners.subscribe(global_listener)

      # local listener
      publisher.subscribe(local_listener)

      expect(global_listener).to receive(:it_happened)
      expect(local_listener).to receive(:it_happened)

      publisher.send(:broadcast, :it_happened)
    end

    context 'with :scope option' do
      let(:anonymous_class_1) { publisher_class }
      let(:anonymous_class_2) { publisher_class }
      let(:anonymous_class_3) { publisher_class }

      before do
        Publisher1 = publisher_class
        Publisher2 = publisher_class
        Publisher3 = publisher_class
      end

      after do
        Object.send(:remove_const, :Publisher1)
        Object.send(:remove_const, :Publisher2)
        Object.send(:remove_const, :Publisher3)
      end

      it 'can be scoped to constant classes and anonymous classes' do
        Wisper::GlobalListeners.subscribe(global_listener, scope: [Publisher1, 'Publisher2', anonymous_class_1, anonymous_class_2.to_s])

        expect(global_listener).to receive(:it_happened_1).once
        expect(global_listener).to receive(:it_happened_2).once
        expect(global_listener).not_to receive(:it_happened_3)
        expect(global_listener).to receive(:it_happened_4).once
        expect(global_listener).to receive(:it_happened_5).once
        expect(global_listener).not_to receive(:it_happened_6)

        Publisher1.new.send(:broadcast, :it_happened_1)
        Publisher2.new.send(:broadcast, :it_happened_2)
        Publisher3.new.send(:broadcast, :it_happened_3)
        anonymous_class_1.new.send(:broadcast, :it_happened_4)
        anonymous_class_2.new.send(:broadcast, :it_happened_5)
        anonymous_class_3.new.send(:broadcast, :it_happened_6)
      end
    end

    it 'is threadsafe' do
      num_threads = 100
      (1..num_threads).to_a.map do
        Thread.new do
          Wisper::GlobalListeners.subscribe(Object.new)
          sleep(rand) # a little chaos
        end
      end.each(&:join)

      expect(Wisper::GlobalListeners.listeners.size).to eq num_threads
    end
  end

  describe '.listeners' do
    it 'returns collection of global listeners' do
      Wisper::GlobalListeners.subscribe(global_listener)
      expect(Wisper::GlobalListeners.listeners).to eq [global_listener]
    end

    it 'returns an immutable collection' do
      expect(Wisper::GlobalListeners.listeners).to be_frozen
      expect { Wisper::GlobalListeners.listeners << global_listener }.to raise_error(RuntimeError)
    end
  end

  it '.clear clears all global listeners' do
    Wisper::GlobalListeners.subscribe(global_listener)
    Wisper::GlobalListeners.clear
    expect(Wisper::GlobalListeners.listeners).to be_empty
  end
end
