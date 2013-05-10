require 'spec_helper'

describe 'async option' do
  let(:listener)  { double('listener') }
  let(:publisher) { Object.new.extend(Wisper) }

  it 'it raises a deprecation exception' do
      expect { publisher.add_listener(listener, :async => true) }.to raise_error
  end
end
