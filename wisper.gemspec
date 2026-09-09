# frozen_string_literal: true

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wisper/version'

Gem::Specification.new do |gem|
  gem.name          = 'wisper'
  gem.version       = Wisper::VERSION
  gem.authors       = ['Kris Leech']
  gem.email         = ['kris.leech@gmail.com']
  gem.description   = <<-DESC
    A micro library providing objects with Publish-Subscribe capabilities.
    Both synchronous (in-process) and asynchronous (out-of-process) subscriptions are supported.
    Check out the Wiki for articles, guides and examples: https://github.com/krisleech/wisper/wiki
  DESC
  gem.summary       = 'A micro library providing objects with Publish-Subscribe capabilities'
  gem.homepage      = 'https://github.com/krisleech/wisper'
  gem.license       = 'MIT'

  gem.required_ruby_version = '>= 3.2'

  # Dir.home raises if it can't determine a home directory (e.g. HOME and
  # USER are both unset, as on some minimal CI containers); ENV['HOME']
  # degrades gracefully to an empty string instead, so this gem can still
  # build without a signing key in that case.
  # rubocop:disable-next Style/EnvHome
  signing_key = File.expand_path("#{ENV.fetch('HOME', nil)}/.ssh/gem-private_key.pem")

  if File.exist?(signing_key)
    gem.signing_key = signing_key
    gem.cert_chain  = ['gem-public_cert.pem']
  end

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR).reject { |f| f.start_with?(%r{(bin|spec)/}) }
  gem.require_paths = ['lib']
  gem.metadata['rubygems_mfa_required'] = 'true'
end
