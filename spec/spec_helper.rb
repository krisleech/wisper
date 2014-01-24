require 'coveralls'
Coveralls.wear!

require 'wisper'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.after(:each) { Wisper::GlobalListeners.clear }

  # Support both Rspec2 should and Rspec3 expect syntax
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
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
