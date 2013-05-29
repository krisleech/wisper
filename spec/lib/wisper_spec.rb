require 'spec_helper'

describe Wisper do
  it 'includes Wisper::Publisher for backwards compatibility' do
    silence_warnings do
      publisher_class = Class.new { include Wisper }
      publisher_class.ancestors.should include Wisper::Publisher
    end
  end
end

# prevents warning showing up in spec output
def silence_warnings
  original_verbosity = $VERBOSE
  $VERBOSE = nil
  yield
  $VERBOSE = original_verbosity
end
