# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wisper/version'

Gem::Specification.new do |gem|
  gem.name          = "wisper"
  gem.version       = Wisper::VERSION
  gem.authors       = ["Kris Leech"]
  gem.email         = ["kris.leech@gmail.com"]
  gem.description   = 'A micro library providing Ruby objects with Publish-Subscribe capabilities'
  gem.summary       = 'A micro library providing Ruby objects with Publish-Subscribe capabilities'
  gem.homepage      = "https://github.com/krisleech/wisper"
  gem.license       = "MIT"

  gem.required_ruby_version = '>= 1.9.3'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
