# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  skip '/spec/'
  enable_coverage :branch
  minimum_coverage line: 100, branch: 100
end

require 'wisper'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.after { Wisper::GlobalListeners.clear }

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
