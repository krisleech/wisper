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

    expected = [instance_of(MyPublisher)]
    expected.push({}) if RUBY_VERSION < "2.7"

    expect(listener).to receive(:foo).with(*expected)
    expect(listener).to receive(:bar).with(*expected)

    my_publisher = MyPublisher.new
    my_publisher.subscribe(listener)
    my_publisher.do_something
  end
end
