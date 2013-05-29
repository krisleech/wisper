# Wisper

Simple pub/sub for Ruby objects

[![Code Climate](https://codeclimate.com/github/krisleech/wisper.png)](https://codeclimate.com/github/krisleech/wisper)
[![Build Status](https://travis-ci.org/krisleech/wisper.png?branch=master)](https://travis-ci.org/krisleech/wisper)

While this is not dependent on Rails in any way it was extracted from a Rails
project and can used as an alternative to ActiveRecord callbacks and Observers.

The problem with callbacks and Observers is that they always happen. How many
times have you wanted to do `User.create` without firing off a welcome email?

It is also super useful for integrating web socket notifications, statistics
and activity streams in to your controller layer without coupling them to your 
models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wisper', '~>1.0.0'
```

## Usage

Any class with the Wisper module included can broadcast events to subscribed
listeners. Listeners are added, at runtime, to the publishing object.

### Publishing

```ruby
class MyPublisher
  include Wisper::Publisher

  def do_something
    # ...
    publish(:done_something, self)
  end
end
```

When the publisher publishes an event it can pass any number of arguments which 
are passed on to the listeners.

```ruby
publish(:done_something, self, 'hello', 'world')
```

### Subscribing

#### Listeners

Any object can be a listener and by default they are only subscribed to events
they can respond to.

```ruby
my_publisher = MyPublisher.new
my_publisher.subscribe(MyListener.new)
```

#### Blocks

Blocks are subscribed to single events.

```ruby
my_publisher = MyPublisher.new
my_publisher.on(:done_something) do |publisher|
  # ...
end
```

### Asynchronous Publishing

Please refer to the [wisper-async](https://github.com/krisleech/wisper-async) gem.

### ActiveRecord

```ruby
class Bid < ActiveRecord::Base
  include Wisper::Publisher

  validates :amount, :presence => true

  def commit(_attrs = nil)
    assign_attributes(_attrs) if _attrs.present?
    if valid?
      save!
      publish(:create_bid_successful, self)
    else
      publish(:create_bid_failed, self)
    end
  end
end
```

### ActionController

```ruby
class BidsController < ApplicationController
  def new
    @bid = Bid.new
  end

  def create
    @bid = Bid.new(params[:bid])

    @bid.subscribe(PusherListener.new)
    @bid.subscribe(ActivityListener.new)
    @bid.subscribe(StatisticsListener.new)

    @bid.on(:create_bid_successful) { |bid| redirect_to bid }
    @bid.on(:create_bid_failed)     { |bid| render :action => :new }

    @bid.commit
  end
end
```

A full CRUD example is shown in the [Wiki](https://github.com/krisleech/wisper/wiki).

### Service/Use Case/Command objects

A Service object is useful when an operation is complex, interacts with more
than one model, accesses an external API or would burden a model with too much
responsibility.

```ruby
class PlayerJoiningTeam
  include Wisper::Publisher

  def execute(player, team)
    membership = Membership.new(player, team)

    if membership.valid?
      membership.save!
      email_player(player, team)
      assign_first_mission(player, team)
      publish(:player_joining_team_successful, player, team)
    else
      publish(:player_joining_team_failed, player, team)
    end
  end

  private

  def email_player(player, team)
    # ...
  end

  def assign_first_mission(player, team)
    # ...
  end
end
```

### Example listeners

These are typical app wide listeners which have a method for pretty much every
event which is broadcast.

```ruby
class PusherListener
  def create_thing_successful(thing)
    # ...
  end
end

class ActivityListener
  def create_thing_successful(thing)
    # ...
  end
end

class StatisticsListener
  def create_thing_successful(thing)
    # ...
  end
end

class CacheListener
  def create_thing_successful(thing)
    # ...
  end
end

class IndexingListener
  def create_thing_successful(thing)
    # ...
  end
end
```

## Global listeners

If you become tired of adding the same listeners to _every_ publisher you can
add global listeners. They receive all published events which they can respond
to.

However it means that when looking at the code it will not be obvious that the
global listeners are being executed in additional to the regular listeners.

```ruby
Wisper::GlobalListeners.add_listener(MyListener.new)
```

In a Rails app you might want to add your global listeners in an initalizer.

Global listeners are threadsafe.

## Temporary Global Listeners

You can also globally subscribe listeners for the duration of a block.

```ruby
Wisper.with_listeners(MyListener.new, OtherListener.new) do
  # do stuff
end
```

Any events broadcast within the block by any publisher will be sent to the
listeners.

## Subscribing to selected events

By default a listener will get notified of all events it can respond to. You
can limit which events a listener is notified of by passing an event or array
of events to `:on`.

```ruby
post_creater.subscribe(PusherListener.new, :on => :create_post_successful)
```

## Mapping event to a different method

By default the method called on the subscriber is the same as the event
broadcast. However it can be mapped to a different method using `:with`.

```ruby
report_creator.subscribe(MailResponder.new, :with => :successful)
```

In the above case it is pretty useless unless used in conjuction with `:on`
since all events will get mapped to `:successful`. Instead you might do
something like this:

```ruby
report_creator.subscribe(MailResponder.new, :on   => :create_report_successful,
                                            :with => :successful)
```

If you pass an array of events to `:on` each event will be mapped to the same
method when `:with` is specified. If you need to listen for select events
_and_ map each one to a different method subscribe the listener once for
each mapping:

```ruby
report_creator.subscribe(MailResponder.new, :on   => :create_report_successful,
                                            :with => :successful)

report_creator.subscribe(MailResponder.new, :on   => :create_report_failed,
                                            :with => :failed)
```

## Chaining subscriptions

```ruby
post.on(:success) { |post| redirect_to post }
    .on(:failure) { |post| render :action => :edit, :locals => :post => post }
```

## RSpec

Wisper comes with a method for stubbing event publishers so that you can create isolation tests
that only care about reacting to events.

Given this piece of code:

```ruby
class CodeThatReactsToEvents
  def do_something
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

describe CodeThatReactsToEvents do
  context "on some_event" do
    before do
      stub_wisper_publisher("MyPublisher", :execute, :some_event, "foo")
    end

    it "renders" do
      response = CodeThatReactsToEvents.new.do_something
      response.should == "Hello with foo!"
    end
  end
end
```

This becomes important when testing, for example, Rails controllers in
isolation from the business logic.  This technique is used at the controller
layer to isolate testing the controller from testing the encapsulated business
logic.

You can use any number of args to pass to the event:

```ruby
stub_wisper_publisher("MyPublisher", :execute, :some_event, "foo1", "foo2", ...)
```

See `spec/lib/rspec_extensions_spec.rb` for a runnable example.

## Compatibility

Tested with MRI 1.9.x, MRI 2.0.0, JRuby (1.9 and 2.0 mode) and Rubinius (1.9
mode).
See the [build status](https://travis-ci.org/krisleech/wisper) for details.

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
