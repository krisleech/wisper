require 'minitest/autorun'

require 'wisper'
require_relative  '../lib/wisper/minitest/stub_wisper_publisher'

# returns an anonymous wispered class
def publisher_class
  Class.new { include Wisper::Publisher }
end

# prevents deprecation warning showing up in spec output
def silence_warnings
  original_verbosity = $VERBOSE
  $VERBOSE = nil
  yield
  $VERBOSE = original_verbosity
end
