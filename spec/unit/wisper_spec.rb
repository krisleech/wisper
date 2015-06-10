describe Wisper do
  describe '.subscribe' do
    let(:listener) { double('Listener') }

    context 'when given block' do
      it 'subscribes listener to temporary listeners' do
        expect(Wisper::TemporaryListeners).to receive(:subscribe).with(listener)
        Wisper.subscribe(listener) {  }
      end
    end

    context 'when no block given' do
      it 'subscribes listener to global listeners' do
        expect(Wisper::GlobalListeners).to receive(:subscribe).with(listener)
        Wisper.subscribe(listener)
      end

      it 'subscribes listeners to global listeners' do
        another_listener = double('listener')
        expect(Wisper::GlobalListeners).to receive(:subscribe).with(listener, another_listener)
        Wisper.subscribe(listener, another_listener)
      end
    end
  end

  describe '.publisher' do
    it 'returns the Publisher module' do
      expect(Wisper.publisher).to eq Wisper::Publisher
    end
  end

  describe '.clear' do
    before { Wisper.subscribe(double) }

    it 'clears all global listeners' do
      expect(Wisper::GlobalListeners).to receive(:clear).twice # [1]
      Wisper.clear
    end
  end

  describe '.configuration' do
    it 'returns configuration object' do
      expect(Wisper.configuration).to be_an_instance_of(Wisper::Configuration)
    end

    it 'is memorized' do
      expect(Wisper.configuration).to eq Wisper.configuration
    end
  end

  describe '.configure' do
    it 'passes configuration to given block' do
      Wisper.configure do |config|
        expect(config).to be_an_instance_of(Wisper::Configuration)
      end
    end
  end

  describe '.setup' do
    it 'sets a default broadcaster' do
      expect_any_instance_of(Wisper::Configuration).to receive(:broadcaster).with(:default, anything)
      Wisper.setup
    end
  end
end

# [1] clear is called in an after spec hook, so twice is used instead of once.
