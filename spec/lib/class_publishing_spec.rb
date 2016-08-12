class MyClassThatPublishes
  include Wisper::Publisher

  def self.do_something
    broadcast(:event, data: 123)
  end
end

describe 'class level publishing' do
  it 'subscribes class listener to class events' do
    listener = double('listener')
    expect(listener).to receive(:event).with(data: 123)

    MyClassThatPublishes.subscribe(listener)
    MyClassThatPublishes.do_something
  end

  it 'doesn\'t subscribe instance listener to class events' do
    listener = double('listener')
    expect(listener).to_not receive(:event).with(data: 123)

    MyClassThatPublishes.new.subscribe(listener)
    MyClassThatPublishes.do_something
  end
end
