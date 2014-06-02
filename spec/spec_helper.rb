require 'coveralls'
Coveralls.wear!

require 'wisper'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.after(:each) { Wisper::GlobalListeners.clear }

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

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
