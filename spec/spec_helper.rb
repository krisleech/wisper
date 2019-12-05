require 'coveralls'
Coveralls.wear!

require 'wisper'

module PublisherHelpers
  # returns an anonymous wispered class
  def publisher_class
    Class.new { include Wisper::Publisher }
  end

  # returns an anonymous wispered module
  def publisher_module
    Module.new { include Wisper::Publisher }
  end
end

RSpec.configure do |config|
  config.include PublisherHelpers

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
