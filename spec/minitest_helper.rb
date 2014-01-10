require 'minitest/autorun'
begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'wisper'

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
