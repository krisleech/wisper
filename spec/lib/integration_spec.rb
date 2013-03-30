require 'spec_helper'

# Example
class MyCommand
  include Wisper

  def execute(be_successful)
    if be_successful
      broadcast('success', 'hello')
    else
      broadcast('failure', 'world')
    end
  end
end

describe Wisper do

  it 'subscribes object to all published events' do
    listener = double('listener')
    listener.should_receive(:success).with('hello')

    command = MyCommand.new

    command.add_listener(listener)

    command.execute(true)
  end

  it 'subscribes block to all published events' do
    insider = double('Insider')
    insider.should_receive(:render).with('hello')

    command = MyCommand.new

    command.add_block_listener do |message|
      insider.render(message)
    end

    command.execute(true)
  end

  it 'subscribes block can be chained' do
    insider = double('Insider')
    insider.should_receive(:render).with('success')

    command = MyCommand.new

    command.on(:success) { |message| insider.render('success') }
           .on(:failure) { |message| insider.render('failure') }

    command.execute(true)
  end
end
