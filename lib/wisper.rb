require 'set'
require 'wisper/version'
require 'wisper/publisher'
require 'wisper/registration/registration'
require 'wisper/registration/object'
require 'wisper/registration/block'
require 'wisper/global_listeners'

module Wisper
  def self.included(base)
    raise 'Backwards incompatible change in v2.0 `include Wisper::Publisher` instead of `include  Wisper`'
  end
end
