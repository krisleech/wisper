begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'wisper'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.after(:each) { Wisper::GlobalListeners.clear }
end

# returns an anonymous wispered class
def publisher_class
  Class.new { include Wisper::Publisher }
end

def publisher_class_with_default_listeners(listeners)
  Class.new do
    include Wisper::Publisher

    define_method :initialize do
      listeners.each{ |l| self.subscribe(l) }
    end
  end
end

# prevents deprecation warning showing up in spec output
def silence_warnings
  original_verbosity = $VERBOSE
  $VERBOSE = nil
  yield
  $VERBOSE = original_verbosity
end
