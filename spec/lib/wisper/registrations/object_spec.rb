# frozen_string_literal: true

describe Wisper::ObjectRegistration do
  describe 'broadcaster' do
    it 'defaults to SendBroadcaster' do
      subject = described_class.new(double('listener'))
      expect(subject.broadcaster).to be_instance_of(Wisper::Broadcasters::SendBroadcaster)
    end

    it 'default is lazily evaluated' do
      expect(Wisper::Broadcasters::SendBroadcaster).not_to receive :new
      described_class.new(double('listener'), broadcaster: double('DifferentBroadcaster').as_null_object)
    end
  end
end
