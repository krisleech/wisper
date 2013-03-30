# Wisper

Simple pub/sub for Ruby objects

[![Code Climate](https://codeclimate.com/github/krisleech/wisper.png)](https://codeclimate.com/github/krisleech/wisper)

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

```ruby
class CreateThing
  include Wisper

  def execute(attributes)
    thing = Thing.new(attributes)
    if thing.valid?
      thing.save!
      broadcast(:create_thing_successful, thing)
    else
      broadcast(:create_thing_failed, thing)
    end
  end
end

class ThingsController < ApplicationController
  def create
    command = CreateThing.new

    command.add_listener(PusherListener.new)
    command.add_listener(ActivityListener.new)
    command.add_listener(StatisticsListener.new)

    command.respond_to(:create_thing_successful) do |thing|
      redirect_to thing
    end

    command.respond_to(:create_thing_failed) do |thing|
      @thing = thing
      render :action => :new
    end

    command.execute(params[:thing])
  end
end

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
