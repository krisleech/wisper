module Wisper
  describe Configuration do
    describe 'broadcasters' do
      let(:broadcaster) { double }
      let(:key)         { :default }

      it '#broadcasters returns empty collection' do
        expect(subject.broadcasters).to be_empty
      end

      it '#broadcaster adds given broadcaster' do
        subject.broadcaster(key, broadcaster)
        expect(subject.broadcasters).to include key
        expect(subject.broadcasters[key]).to eql broadcaster
      end
    end
  end
end
