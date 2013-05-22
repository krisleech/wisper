require 'spec_helper'

class MyPublisher
  include Wisper::Publisher

  def do_something
    # ...
    broadcast(:bar, self)
    broadcast(:foo, self)
  end
end

describe 'simple publishing' do
  it 'subscribes listener to events' do
    listener = double('listener')
    listener.should_receive(:foo).with instance_of MyPublisher
    listener.should_receive(:bar).with instance_of MyPublisher

    my_publisher = MyPublisher.new
    my_publisher.add_listener(listener)
    my_publisher.do_something
  end
end
