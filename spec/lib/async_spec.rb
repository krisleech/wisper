require 'spec_helper'

require 'celluloid/autostart'

class MyService
  include Wisper

  def execute
    broadcast('success', self)
  end
end

# help me...
$global = 'no'

class MyListener
  include Celluloid

  def success(command)
    $global = 'yes'
    terminate
  end
end

describe Wisper do

  it 'subscribes object to all published events' do
    listener = MyListener.new

    command = MyService.new

    command.add_listener(listener, :async => true)

    command.execute
    sleep(0.1) # seriously...
    $global.should == 'yes'
  end
end

