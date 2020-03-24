describe Wisper::ObjectRegistration do
  let(:listener) { double('listener') }

  describe 'broadcaster' do
    it 'defaults to SendBroadcaster' do
      subject = Wisper::ObjectRegistration.new(listener, {})
      expect(subject.broadcaster).to be_instance_of(Wisper::Broadcasters::SendBroadcaster)
    end

    it 'default is lazily evaluated' do
      expect(Wisper::Broadcasters::SendBroadcaster).to_not receive :new
      Wisper::ObjectRegistration.new(listener, broadcaster: double('DifferentBroadcaster').as_null_object)
    end
  end

  describe 'allowed_classes' do
    subject { Wisper::ObjectRegistration.new(listener, scope: scope) }

    let(:anonymous_class_1) { publisher_class }
    let(:anonymous_class_2) { publisher_class }
    let(:anonymous_module_1) { publisher_module }
    let(:anonymous_module_2) { publisher_module }
    let(:scope) do
      [
        Publisher1, 'Publisher2', Publisher3, 'Publisher4',
        anonymous_class_1, anonymous_class_2.to_s, anonymous_module_1, anonymous_module_2.to_s,
        nil, '', '   '
      ]
    end

    before do
      Publisher1 = publisher_class
      Publisher2 = publisher_class
      Publisher3 = publisher_module
      Publisher4 = publisher_module
    end

    after do
      Object.send(:remove_const, :Publisher1)
      Object.send(:remove_const, :Publisher2)
      Object.send(:remove_const, :Publisher3)
      Object.send(:remove_const, :Publisher4)
    end

    it 'contains constant/anonymous classes/modules' do
      expect(subject.allowed_classes).to contain_exactly(
        Publisher1,
        Publisher2,
        Publisher3,
        Publisher4,
        anonymous_class_1,
        anonymous_class_2.to_s,
        anonymous_module_1,
        anonymous_module_2.to_s
      )
    end

    context 'when scope contains duplicated classes' do
      let(:scope) { [Publisher1, 'Publisher1'] }

      it 'does not contain duplicated classes' do
        expect(subject.allowed_classes.length).to eq(1)
      end
    end

    context 'when scope contains nil or blank strings' do
      let(:scope) { [nil, '', '   '] }

      it 'does not contain anything' do
        expect(subject.allowed_classes.length).to eq(0)
      end
    end
  end
end
