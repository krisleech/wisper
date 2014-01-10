require 'pry'
### Wisper Stubbing
# This is a proposal for integration as part of wisper core
# for testing: https://github.com/krisleech/wisper/issues/1
class Object
  class TestWisperPublisher
    include Wisper::Publisher
    def initialize(*args); end
  end

  def stub_wisper_publisher(class_name, called_method, event_to_publish, *published_event_args)
    existing_class = Object.constants.detect{|c| c == class_name}.nil? ? nil : Object.const_get(class_name)

    fake_class = Class.new(TestWisperPublisher) do
      define_method(called_method) do |*args|
        publish(event_to_publish, *published_event_args)
      end
    end
    Object.const_set(class_name, fake_class)

    yield
  ensure
    Object.const_set(class_name, existing_class)
  end
end
