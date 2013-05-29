require 'spec_helper'

describe Wisper do

  def publisher_class
    Class.new { include Wisper::Publisher }
  end

  it 'includes Wisper::Publisher for backwards compatibility' do
    silence_warnings do
      publisher_class = Class.new { include Wisper }
      publisher_class.ancestors.should include Wisper::Publisher
    end
  end

  it '.with_listeners subscribes listeners to all broadcast events for the duration of block' do
    publisher = publisher_class.new
    listener = double('listener')

    listener.should_receive(:im_here)
    listener.should_not_receive(:not_here)

    Wisper.with_listeners(listener) do
      publisher.send(:broadcast, 'im_here')
    end

    publisher.send(:broadcast, 'not_here')
  end
end

# prevents deprecation warning showing up in spec output
def silence_warnings
  original_verbosity = $VERBOSE
  $VERBOSE = nil
  yield
  $VERBOSE = original_verbosity
end
