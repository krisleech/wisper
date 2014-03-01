require 'spec_helper'

describe 'class subscriber' do
  let(:publisher)        { publisher_class.new }

  describe '.add_class' do
    it 'adds a class listener to every publisher' do
      Wisper::GlobalListeners.add_class(FakeListener)
      publisher.send(:broadcast, :it_happened)
      expect(FakeListener.is_called).to be(true)
    end
  end
end

class FakeListener
  def self.is_called
    @@is_called
  end

  def it_happened
    @@is_called = true
  end
end
