require 'set'
require 'wisper/version'
require 'wisper/publisher'
require 'wisper/registration/registration'
require 'wisper/registration/object'
require 'wisper/registration/block'
require 'wisper/global_listeners'

module Wisper
  def self.included(base)
    warn "[DEPRECATION] `include Wisper::Publisher` instead of `include Wisper`"
    base.class_eval { include Wisper::Publisher  }
  end
end
