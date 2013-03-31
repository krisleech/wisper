# Wisper

Simple pub/sub for Ruby objects

[![Code Climate](https://codeclimate.com/github/krisleech/wisper.png)](https://codeclimate.com/github/krisleech/wisper)
[![Build Status](https://travis-ci.org/krisleech/wisper.png)](https://travis-ci.org/krisleech/wisper)

While this is not dependent on Rails in any way it was extracted from a Rails
project and is used as an alternative to ActiveRecord callbacks and Observers.

The problem with callbacks and Observers is that they always happen. How many
times have you wanted to do `User.create` without firing off a welcome email?

It is also super useful for integrating web socket notifications, statistics
and activity streams in to your controller layer without coupling them to your 
models.

## Installation

Add this line to your application's Gemfile:

    gem 'wisper'

## Usage

Any class with the Wisper module included can broadcast events to subscribed
listeners. Listeners are added, at runtime, to the publishing object.

### Publishing

```ruby
class MyPublisher
  include Wisper

  def do_something
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

The listener is subscribed to all events it responds to.

```ruby
listener = Object.new # any object
my_publisher = MyPublisher.new
my_publisher.subscribe(listener)
```

#### Blocks

The block is subscribed to a single event.

```ruby
my_publisher = MyPublisher.new
my_publisher.on(:done_something) do |publisher|
  # ...
end
```

### ActiveRecord

```ruby
class Post < ActiveRecord::Base
  include Wisper

  def create
    if save
      publish(:create_post_successful, self)
    else
      publish(:create_post_failed, self)
    end
  end
end
```

### ActionController

```ruby
class PostsController < ApplicationController
  def create
    @post = Post.new(params[:post])

    @post.subscribe(PusherListener.new)
    @post.subscribe(ActivityListener.new)
    @post.subscribe(StatisticsListener.new)

    @post.on(:create_post_successful) { |post| redirect_to post }
    @post.on(:create_post_failed)     { |post| render :action => :new }

    @post.create
  end
end
```

### Service/Use case object

The downside to publishing directly from ActiveRecord models is that an event
can get fired and then rolled back if a transaction fails.

Since I am trying to make my models dumb I tend to use a separate service 
object which contains all the logic and wraps it all in a transaction.

The follow is contrived, but you can imagine it doing more than just updating a
record, maybe sending an email or updating other records.

```ruby
class CreateThing
  include Wisper

  def execute(attributes)
    thing = Thing.new(attributes)

    if thing.valid?
      ActiveRecord::Base.transaction do
        thing.save
        # ...
      end
      publish(:create_thing_successful, thing)
    else
      publish(:create_thing_failed, thing)
    end
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
```

## Subscribing to selected events

By default a listener will get notified of all events it responds to. You can
limit which events a listener is notified of by passing an event or array of
events to `:on`.

```ruby
post_creater.subscribe(PusherListener.new, :on => :create_post_successful)
```

## Chaining subscriptions

```ruby
post.on(:success) { |post| redirect_to post }
    .on(:failure) { |post| render :action => :edit, :locals => :post => post }
```

## Compatibility

Tested with 1.9.x on MRI, JRuby and Rubinius.
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
