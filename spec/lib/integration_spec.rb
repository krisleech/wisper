# Example
class MyCommand
  include Wisper::Publisher

  def execute(be_successful)
    if be_successful
      broadcast('success', 'hello')
    else
      broadcast('failure', 'world')
    end
  end
end

class MyCommandWithConstructor
  include Wisper::Publisher

  def initialize(message)
    @message = message
  end

  def execute
    broadcast('success', @message)
  end
end

describe Wisper do

  it 'subscribes object to all published events' do
    listener = double('listener')
    expect(listener).to receive(:success).with('hello')

    command = MyCommand.new

    command.subscribe(listener)

    command.execute(true)
  end

  it 'maps events to different methods' do
    listener_1 = double('listener')
    listener_2 = double('listener')
    expect(listener_1).to receive(:happy_days).with('hello')
    expect(listener_2).to receive(:sad_days).with('world')

    command = MyCommand.new

    command.subscribe(listener_1, :on => :success, :with => :happy_days)
    command.subscribe(listener_2, :on => :failure, :with => :sad_days)

    command.execute(true)
    command.execute(false)
  end

  it 'subscribes block can be chained' do
    insider = double('Insider')

    expect(insider).to receive(:render).with('success')
    expect(insider).to receive(:render).with('failure')

    command = MyCommand.new

    command.on(:success) { |message| insider.render('success') }
           .on(:failure) { |message| insider.render('failure') }

    command.execute(true)
    command.execute(false)
  end

  it 'publishes events from frozen publishers' do
    listener = double('listener')
    expect(listener).to receive(:success).with('hello')

    command = MyCommand.new
    command.freeze

    Wisper.subscribe(listener) do
      command.execute(true)
    end
  end

  it 'publishes events from frozen publishers with custom constructors' do
    listener = double('listener')
    expect(listener).to receive(:success).with('constructor argument')

    command = MyCommandWithConstructor.new('constructor argument')
    command.freeze

    Wisper.subscribe(listener) do
      command.execute
    end
  end

  it 'raises an exception when attempting to register a local listener on a frozen publisher' do
    listener = double('listener')

    command = MyCommand.new
    command.freeze

    expect { command.subscribe(listener) }.to raise_error(ArgumentError)
  end
end
