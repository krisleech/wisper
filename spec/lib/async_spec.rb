require 'spec_helper'

class MyService
  include Wisper

  def execute
    broadcast('success', self)
  end
end

# help me...
$global = 'no'

class MyListener
  def success(command)
    $global = 'yes'
  end
end

describe Wisper do

  it 'subscribes object to all published events' do
    listener = MyListener.new

    command = MyService.new

    command.add_listener(listener, :async => true)

    command.execute
    sleep(1) # seriously...
    $global.should == 'yes'
  end
end

