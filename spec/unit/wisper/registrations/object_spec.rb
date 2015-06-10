describe Wisper::ObjectRegistration do
  let(:listener) { double('Listener') }

  describe 'broadcaster' do
    it 'fetches default from configuration' do
      expect(Wisper.configuration).to receive(:broadcasters).and_return(double.as_null_object)
      Wisper::ObjectRegistration.new(listener, {})
    end

    it 'default is lazily evaluated' do
      expect(Wisper.configuration).not_to receive(:broadcasters)
      Wisper::ObjectRegistration.new(listener, broadcaster: double('DifferentBroadcaster').as_null_object)
    end
  end
end
