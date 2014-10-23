# Wisper

*A micro library providing Ruby objects with Publish-Subscribe capabilities*

[![Gem Version](https://badge.fury.io/rb/wisper.png)](http://badge.fury.io/rb/wisper)
[![Code Climate](https://codeclimate.com/github/krisleech/wisper.png)](https://codeclimate.com/github/krisleech/wisper)
[![Build Status](https://travis-ci.org/krisleech/wisper.png?branch=master)](https://travis-ci.org/krisleech/wisper)
[![Coverage Status](https://coveralls.io/repos/krisleech/wisper/badge.png?branch=master)](https://coveralls.io/r/krisleech/wisper?branch=master)

* Decouple core business logic from external concerns in Hexagonal style architectures
* Use as an alternative to ActiveRecord callbacks and Observers in Rails apps
* Connect objects based on context without permanence
* React to events synchronously or asynchronously

Note: Wisper was originally extracted from a Rails codebase but is not dependant on Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wisper'
```

## Usage

Any class with the `Wisper::Publisher` module included can broadcast events 
to subscribed listeners. Listeners subscribe, at runtime, to the publisher.

### Publishing

```ruby
class CancelOrder
  include Wisper::Publisher
  
  def call(order_id)
    order = Order.find_by_id(order_id)
    
    # business logic...

    if order.cancelled?
      broadcast(:cancel_order_successful, order.id)
    else
      broadcast(:cancel_order_failed, order.id)
    end
  end
end
```

When a publisher broadcasts an event it can include number of arguments. 

The `broadcast` method is also aliased as `publish` and `announce`.

You can also include `Wisper.publisher` instead of `Wisper::Publisher`.

### Subscribing

#### Objects

Any object can be subscribed as a listener.

```ruby
cancel_order = CancelOrder.new

cancel_order.subscribe(OrderNotifier.new)

cancel_order.call(order_id)
```

The listener would need to implement a method for every event it wishes to receive.

```ruby
class OrderNotifier
  def cancel_order_successful(order_id)
    order = Order.find_by_id(order_id)
       
    # notify someone ...    
  end
end
```

#### Blocks

Blocks can be subscribed to single events and can be chained.

```ruby
cancel_order = CancelOrder.new

cancel_order.on(:cancel_order_successful) { |order_id| ... }
            .on(:cancel_order_failed)     { |order_id| ... }
            
cancel_order.call(order_id)
```

### Handling Events Asynchronously

```ruby
cancel_order.subscribe(OrderNotifier.new, async: true)
```

Wisper has various adapters for asynchronous event handling, please refer to
[wisper-celluloid](https://github.com/krisleech/wisper-celluloid),
[wisper-sidekiq](https://github.com/krisleech/wisper-sidekiq) or
[wisper-activejob](https://github.com/krisleech/wisper-activejob).

Depending on the adapter used the listener may need to be a class instead of an object.

### ActionController

```ruby
class CancelOrderController < ApplicationController
 
  def create
    cancel_order = CancelOrder.new

    cancel_order.subscribe(OrderMailer,        async: true)
    cancel_order.subscribe(ActivityRecorder,   async: true)
    cancel_order.subscribe(StatisticsRecorder, async: true)

    cancel_order.on(:cancel_order_successful) { |order_id| redirect_to order_path(order_id) }
    cancel_order.on(:cancel_order_failed)     { |order_id| render action: :new }

    cancel_order.call(order_id)
  end
end
```

### ActiveRecord

If you wish to publish directly from ActiveRecord models you can broadcast events from callbacks:

```ruby
class Order < ActiveRecord::Base
  include Wisper::Publisher
  
  after_commit     :publish_creation_successful, on: :create
  after_validation :publish_creation_failed,     on: :create

  private

  def publish_creation_successful
    broadcast(:order_creation_successful, self)
  end

  def publish_creation_failed
    broadcast(:order_creation_failed, self) if errors.any?
  end
end
```

There are more examples in the [Wiki](https://github.com/krisleech/wisper/wiki).

## Global Listeners

Global listeners receive all broadcast events which they can respond to.

This is useful for cross cutting concerns such as recording statistics, indexing, caching and logging.

```ruby
Wisper.subscribe(MyListener.new)
```

In a Rails app you might want to add your global listeners in an initalizer.

Global listeners are threadsafe.

### Scoping by publisher class

You might want to globally subscribe a listener to publishers with a certain
class.

```ruby
Wisper.subscribe(MyListener.new, scope: :MyPublisher)
```

This will subscribe the listener to all instances of `MyPublisher` and its
subclasses.

Alternatively you can also do exactly the same with a publisher class itself:

```ruby
MyPublisher.subscribe(MyListener.new)
```

## Temporary Global Listeners

You can also globally subscribe listeners for the duration of a block.

```ruby
Wisper.subscribe(MyListener.new, OtherListener.new) do
  # do stuff
end
```

Any events broadcast within the block by any publisher will be sent to the
listeners. 

This is useful for capturing events published by objects to which you do not have access in a given context.

Temporary Global Listeners are threadsafe.

## Subscribing to selected events

By default a listener will get notified of all events it can respond to. You
can limit which events a listener is notified of by passing an event or array
of events to `on:`.

```ruby
post_creater.subscribe(PusherListener.new, on: :create_post_successful)
```

## Prefixing broadcast events

If you would prefer listeners to receive events with a prefix, for example
`on`, you can do so by passing a string or symbol to `prefix:`.

```ruby
post_creater.subscribe(PusherListener.new, prefix: :on)
```

If `post_creater` where to broadcast the event `post_created` the subscribed
listeners would receive `on_post_created`. You can also pass `true` which will
use the default prefix, "on".

## Mapping an event to a different method

By default the method called on the subscriber is the same as the event
broadcast. However it can be mapped to a different method using `with:`.

```ruby
report_creator.subscribe(MailResponder.new, with: :successful)
```

This is pretty useless unless used in conjuction with `on:`, since all events
will get mapped to `:successful`. Instead you might do something like this:

```ruby
report_creator.subscribe(MailResponder.new, on:   :create_report_successful,
                                            with: :successful)
```

If you pass an array of events to `on:` each event will be mapped to the same
method when `with:` is specified. If you need to listen for select events
_and_ map each one to a different method subscribe the listener once for
each mapping:

```ruby
report_creator.subscribe(MailResponder.new, on:   :create_report_successful,
                                            with: :successful)

report_creator.subscribe(MailResponder.new, on:   :create_report_failed,
                                            with: :failed)
```

You could also alias the method within your listener, as such
`alias successful create_report_successful`.

## RSpec

### Broadcast Matcher

```ruby
require 'wisper/rspec/matchers'

RSpec::configure do |config|
  config.include(Wisper::RSpec::BroadcastMatcher)
end

expect { publisher.execute }.to broadcast(:an_event)
```

### Using message expections

If you need to assert on the arguments broadcast you can subscribe a double 
with a [message expection](https://github.com/rspec/rspec-mocks#message-expectations)
and then use any of the [argument matchers](https://github.com/rspec/rspec-mocks#argument-matchers).

```ruby
listener = double('Listener')

expect(listener).to receive(:an_event).with(some_args)

publisher.subscribe(listener)

publisher.execute
```

### Stubbing publishers

You can stub publishers and their events in unit (isolated) tests that only care about reacting to events.

Given this piece of code:

```ruby
class MyController
  def create
    publisher = MyPublisher.new
    
    publisher.on(:some_event) do |variable|
      return "Hello with #{variable}!"
    end
    
    publisher.execute
  end
end
```

You can test it like this:

```ruby
require 'wisper/rspec/stub_wisper_publisher'

describe MyController do
  context "on some_event" do
    before do
      stub_wisper_publisher("MyPublisher", :execute, :some_event, "foo")
    end

    it "renders" do
      response = MyController.new.create
      expect(response).to eq "Hello with foo!"
    end
  end
end
```

This is useful when testing Rails controllers in isolation from the business logic.  

You can use any number of args to pass to the event:

```ruby
stub_wisper_publisher("MyPublisher", :execute, :some_event, "foo1", "foo2", ...)
```

See `spec/lib/rspec_extensions_spec.rb` for a runnable example.

## Clearing Global Listeners

If you use global listeners in non-feature tests you _might_ want to clear them
in a hook to prevent global subscriptions persisting between tests.

```ruby
after { Wisper.clear }
```

## Compatibility

Tested with MRI 1.9.x, MRI 2.0.0, JRuby (1.9 and 2.0 mode) and Rubinius (1.9
mode).

See the [build status](https://travis-ci.org/krisleech/wisper) for details.

## Running Specs

```
rspec spec
```

There is both a `Rakefile` and `Guardfile`, if you like you prefer to run the
specs using `guard-rspec` or `rake`.

## License

(The MIT License)

Copyright (c) 2013 Kris Leech

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
