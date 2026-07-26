# frozen_string_literal: true

describe Wisper::ValueObjects::Events do
  context 'nil' do
    subject { described_class.new nil }

    describe '#include?' do
      it 'returns true' do
        expect(subject).to include('foo')
        expect(subject).to include(:bar)
      end
    end
  end

  context '"foo"' do
    subject   { described_class.new foo }

    let(:foo) { Class.new(String).new 'foo' }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject).to include('foo')
      end

      it 'returns true for :foo' do
        expect(subject).to include(:foo)
      end

      it 'returns false otherwise' do
        expect(subject).not_to include('bar')
        expect(subject).not_to include(:bar)
      end
    end
  end

  context ':foo' do
    subject { described_class.new :foo }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject).to include('foo')
      end

      it 'returns true for :foo' do
        expect(subject).to include(:foo)
      end

      it 'returns false otherwise' do
        expect(subject).not_to include('bar')
        expect(subject).not_to include(:bar)
      end
    end
  end

  context '[:foo, "bar"]' do
    subject { described_class.new [:foo, 'bar'] }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject).to include('foo')
      end

      it 'returns true for :foo' do
        expect(subject).to include(:foo)
      end

      it 'returns true for "bar"' do
        expect(subject).to include('bar')
      end

      it 'returns true for :bar' do
        expect(subject).to include(:bar)
      end

      it 'returns false otherwise' do
        expect(subject).not_to include('baz')
        expect(subject).not_to include(:baz)
      end
    end
  end

  context 'by /foo/' do
    subject { described_class.new(/foo/) }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject).to include('foo')
      end

      it 'returns true for :foo' do
        expect(subject).to include(:foo)
      end

      it 'returns false otherwise' do
        expect(subject).not_to include('bar')
        expect(subject).not_to include(:bar)
      end
    end
  end

  context 'another class' do
    subject { described_class.new Object.new }

    describe '#include?' do
      it 'raises ArgumentError' do
        expect { subject.include? 'foo' }.to raise_error(ArgumentError)
      end
    end
  end
end
