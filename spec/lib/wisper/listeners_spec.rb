require 'spec_helper'

describe Wisper::Listeners do
  let(:listeners)     { Wisper::Listeners.new(publisher, registrations) }
  let(:listener)      { double('listener', :to_a => nil) } # [1]
  let(:publisher)     { Object.new.extend(Wisper::Publisher) }
  let(:registrations) { [] }

  it 'is immutable' do
    listeners.frozen?.should be_true
    expect { listeners << Object.new }.to raise_error(RuntimeError, /can't modify/)
  end

  it 'is an enumerator' do
    publisher.listeners.is_a?(Enumerator)
  end

  describe '.add' do
    it 'adds a listener to given publisher' do
      listeners.add(listener)
      publisher.listeners.should == [listener]
    end

    it 'adds listeners to given publisher' do
      listener_2 = double('listener')
      listeners.add([listener, listener_2])
      publisher.listeners.should == [listener, listener_2]
    end

    it 'returns a new object' do
      before_object_id = publisher.listeners.object_id
      listeners.add(listener)
      publisher.listeners.object_id.should_not == before_object_id
    end
  end

  describe '.new' do
    it 'given block yields to self' do
      Wisper::Listeners.new(publisher, registrations) do
        add Object.new
        add Object.new
        add Object.new
      end

      publisher.listeners.size.should == 3
    end
  end
end

# [1] `to_a` is stubbed since on 1.9.2 only the double raises an error:
# RSpec::Mocks::MockExpectationError: Mock received unexpected message :to_a
# with (no args)
