module Wisper
  describe Configuration do
    describe 'broadcasters' do
      let(:broadcaster) { double }
      let(:key)         { :default }

      it '#broadcasters returns empty collection' do
        expect(subject.broadcasters).to be_empty
      end

      describe '#broadcaster' do
        it 'adds given broadcaster' do
          subject.broadcaster(key, broadcaster)
          expect(subject.broadcasters).to include key
          expect(subject.broadcasters[key]).to eql broadcaster
        end

        it 'returns the configuration' do
          expect(subject.broadcaster(key, broadcaster)).to eq subject
        end
      end
    end
  end
end
