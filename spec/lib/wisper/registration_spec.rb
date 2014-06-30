require 'spec_helper'

describe Wisper::Registration do
  let(:listener){ double(:listener) }
  let(:registration){ Wisper::Registration.new(listener, options) }
  let(:options){ {} }

  describe '#method_name' do
    specify{ expect(registration.method_name('event')).to eq('event') }

    context 'when option :with is custom_event' do
      let(:options){ { with: 'custom_event' } }
      specify{ expect(registration.method_name('event')).to eq('custom_event') }
    end

    context 'when option :prefix is true' do
      let(:options){ { prefix: true } }
      specify{ expect(registration.method_name('event')).to eq('on_event') }
    end

    context 'when option :prefix is "prefix"' do
      let(:options){ { prefix: 'prefix' } }
      specify{ expect(registration.method_name('event')).to eq('prefix_event') }
    end

    context 'when config option :prefix is true' do
      before{ Wisper.config.prefix = true }
      after{ Wisper.config.prefix = nil }

      specify{ expect(registration.method_name('event')).to eq('on_event') }
    end

    context 'when config option :prefix is "prefix"' do
      before{ Wisper.config.prefix = 'prefix' }
      after{ Wisper.config.prefix = nil }

      specify{ expect(registration.method_name('event')).to eq('prefix_event') }
    end
  end

  describe '#broadcaster' do
    before{ Wisper::Registration.send(:public, :broadcaster) }

    specify{ expect(registration.broadcaster).to be_instance_of(Wisper::Broadcasters::DirectInvocation) }

    context 'when broadcaster is defined by config' do
      before{ Wisper.config.broadcaster = Wisper::Broadcasters::Block }
      after{ Wisper.config.broadcaster = nil }

      specify{ expect(registration.broadcaster).to be_instance_of(Wisper::Broadcasters::Block) }
    end

    context 'when broadcaster is defined by options' do
      let(:options){ { broadcaster: Wisper::Broadcasters::Block } }
      specify{ expect(registration.broadcaster).to be_instance_of(Wisper::Broadcasters::Block) }
    end
  end
end
