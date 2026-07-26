# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'rspec'

group :test do
  # local, dependency-free coverage reporting (replaces the abandoned
  # `coveralls` gem, which pins ancient faraday/thor/tins releases that
  # no longer install on current Ruby)
  gem 'simplecov', require: false
end

group :development do
  # static analysis
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false

  # dependency vulnerability scanning
  gem 'bundler-audit', require: false
end

group :extras do
  gem 'pry'
  gem 'yard'
end
