require 'simplecov'
SimpleCov.start

require 'wisper'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

# returns an anonymous wispered class
def publisher_class
  Class.new { include Wisper::Publisher }
end
